//
//  MainViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import WebKit
import UniformTypeIdentifiers

@MainActor
final class MainViewModel: NSObject, ObservableObject {
    
    private let appState: AppState
    weak var webView: WKWebView?
    private let imageLocalCache = FIFOCache<String, String>(max: 50)
    @Published var isFileExporting: Bool = false
    @Published var exportFileData: DataFile?
    @Published var exportContentType: UTType = .png
    @Published var exportDefaultFilename: String = "out.png"
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - Call Javascript
    private func callbackJavascript(callbackId: String, data: Any? = nil, error: String? = nil) {
        let dataJsonString = serializeToJSONString(data)
        let errorJsonString = serializeToJSONString(error)
        let jsScript = "if(window.__WENYAN_BRIDGE__.invokeCallback) { window.__WENYAN_BRIDGE__.invokeCallback('\(callbackId)', \(dataJsonString), \(errorJsonString)); }"
        WenYan.callJavascript(webView: webView, javascriptString: jsScript)
    }
    
    private func emitJavascript(event: String, data: Any? = nil) {
        let dataJsonString = serializeToJSONString(data)
        let jsScript = "if(window.__WENYAN_BRIDGE__.emit) { window.__WENYAN_BRIDGE__.emit('\(event)', \(dataJsonString)); }"
        WenYan.callJavascript(webView: webView, javascriptString: jsScript)
    }
}

// MARK: - ScriptMessageHandler
extension MainViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "wenyanBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String,
              let callbackId = body["callbackId"] as? String else {
            return
        }
        
        let payload = body["payload"]
        switch action {
        case "loadArticles":
            handleLoadArticles(callbackId: callbackId)
        case "saveArticle":
            handleSaveArticle(payload: payload as? String)
        case "pageInit":
            handlePageInit()
        case "loadThemes":
            handleLoadThemes(callbackId: callbackId)
        case "saveTheme":
            handleSaveTheme(callbackId: callbackId, payload: payload)
        case "removeTheme":
            handleRemoveTheme(payload: payload as? String)
        case "openDirectoryPicker":
            handleOpenDirectoryPicker(callbackId: callbackId)
        case "readDir":
            handleReadDir(callbackId: callbackId, payload: payload as? String)
        case "handleMarkdownFile":
            handleMarkdownFile(callbackId: callbackId, payload: payload as? String)
        case "pathToBase64":
            pathToBase64(callbackId: callbackId, payload: payload as? String)
        case "uploadBase64Image":
            resolveUploadBase64Image(callbackId: callbackId, payload: payload)
        case "handleMarkdownContent":
            handleMarkdownContent(callbackId: callbackId, payload: payload as? String)
        case "uploadImage":
            resolveUploadImage(callbackId: callbackId, payload: payload as? String)
        case "resetLastArticlePath":
            handleResetLastArticlePath()
        case "getCredential":
            handleGetCredential(callbackId: callbackId)
        case "saveCredential":
            handleSaveCredential(payload: payload)
        case "getSettings":
            handleGetSettings(callbackId: callbackId)
        case "saveSettings":
            handleSaveSettings(payload: payload)
        case "openLink":
            handleOpenLink(payload: payload as? String)
        case "autoCacheChange":
            handleAutoCacheChange()
        case "resetWechatAccessToken":
            handleResetWechatAccessToken()
        case "publishArticleToDraft":
            resolvePublishArticleToDraft(callbackId: callbackId, payload: payload)
        case "saveExportedFile":
            handleSaveExportedFile(payload: payload)
        default:
            break
        }
    }
}

// MARK: - Article Handlers
extension MainViewModel {
    func handleLoadArticles(callbackId: String) {
        let article = loadArticle()
        callbackJavascript(callbackId: callbackId, data: article)
    }
    
    func handleSaveArticle(payload: String?) {
        saveArticle(payload)
    }
    
    func handlePageInit() {
        if let article = loadArticle() {
            dispatch(.setContent(article))
        } else {
            do {
                let content = try loadFileFromResource(forResource: "example", withExtension: "md")
                dispatch(.setContent(content))
            } catch {
                dispatch(.onError(error.localizedDescription))
            }
        }
    }
}

// MARK: - Theme Handlers
extension MainViewModel {
    func handleLoadThemes(callbackId: String) {
        do {
            let themes = try fetchCustomThemes().map { $0.toDictionary() }
            callbackJavascript(callbackId: callbackId, data: themes)
        } catch {
            callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
        }
    }
    
    func handleSaveTheme(callbackId: String, payload: Any?) {
        guard let dict = payload as? [String: Any] else {
            callbackJavascript(callbackId: callbackId, error: "不能保存自定义主题")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let themeToSave = try JSONDecoder().decode(JsCustomTheme.self, from: data)
            
            if let theme = try getCustomThemeById(id: themeToSave.id) {
                try updateCustomTheme(customTheme: theme, name: themeToSave.name, content: themeToSave.css)
                callbackJavascript(callbackId: callbackId, data: themeToSave.id)
            } else {
                let result = try saveCustomTheme(name: themeToSave.name, content: themeToSave.css)
                callbackJavascript(callbackId: callbackId, data: result.objectID.uriRepresentation().absoluteString)
            }
        } catch {
            callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
        }
    }
    
    func handleRemoveTheme(payload: String?) {
        guard let idToDelete = payload, let theme = try? getCustomThemeById(id: idToDelete) else {
            dispatch(.onError("不能删除主题"))
            return
        }
        do {
            try deleteCustomTheme(theme)
        } catch {
            dispatch(.onError(error.localizedDescription))
        }
    }
}

// MARK: - Credential Handlers
extension MainViewModel {
    func handleGetCredential(callbackId: String) {
        let credential = getCredential()
        callbackJavascript(callbackId: callbackId, data: credential)
    }
    
    func handleSaveCredential(payload: Any?) {
        if let dict = payload as? [String: Any], let appId = dict["appId"] as? String, let appSecret = dict["appSecret"] as? String {
            saveCredential(credential: GenericCredential(appId: appId, appSecret: appSecret))
        }
    }
}

// MARK: - Settings Handlers
extension MainViewModel {
    func handleGetSettings(callbackId: String) {
        let settings = getSettings()
        callbackJavascript(callbackId: callbackId, data: settings)
    }
    
    func handleSaveSettings(payload: Any?) {
        if let dict = payload as? [String: Any] {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                let settings = try JSONDecoder().decode(Settings.self, from: data)
                saveSettings(settings: settings)
            } catch {
                dispatch(.onError(error.localizedDescription))
            }
        }
    }
}

// MARK: - Directory Handlers
extension MainViewModel {
    func handleOpenDirectoryPicker(callbackId: String) {
        // UI 操作必须在主线程执行
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "选择工作目录"
            panel.canChooseDirectories = true    // 允许选择文件夹
            panel.canChooseFiles = false         // 不允许选择单文件
            panel.allowsMultipleSelection = false // 不允许多选
            panel.canCreateDirectories = true    // 允许新建文件夹
            
            // 弹出模态窗口
            if panel.runModal() == .OK {
                // 用户点击了“打开”或“确定”
                if let url = panel.url {
                    let path = url.path
                    do {
                        try saveSecurityScopedBookmark(for: url)
                    } catch {
                        self.callbackJavascript(callbackId: callbackId, data: "保存目录访问权限失败: \(error.localizedDescription)")
                    }
                    self.callbackJavascript(callbackId: callbackId, data: path)
                } else {
                    // 异常情况，返回 null
                    self.callbackJavascript(callbackId: callbackId, data: nil)
                }
            } else {
                // 用户点击了“取消”或关闭了窗口，返回 null
                self.callbackJavascript(callbackId: callbackId, data: nil)
            }
        }
    }
    
    func handleReadDir(callbackId: String, payload: String?) {
        guard let path = payload else {
            callbackJavascript(callbackId: callbackId, error: "不能读取目录")
            return
        }
        Task { [weak self] in
            guard let self = self else { return }
            let fileManager = FileManager.default
            let url = URL(fileURLWithPath: path)
            var resultEntries: [[String: Any]] = []
            do {
                let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
                for fileUrl in contents {
                    // 检查是否是文件夹
                    let resourceValues = try fileUrl.resourceValues(forKeys: [.isDirectoryKey])
                    let isDirectory = resourceValues.isDirectory ?? false
                    
                    // 构造前端需要的 FileEntry 结构字典
                    let entryDict: [String: Any] = [
                        "name": fileUrl.lastPathComponent,
                        "path": fileUrl.path, // 绝对路径
                        "isDirectory": isDirectory
                    ]
                    resultEntries.append(entryDict)
                }
                self.callbackJavascript(callbackId: callbackId, data: resultEntries, error: nil)
            } catch {
                self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
            }
        }
    }
    
    /// open file
    func handleMarkdownFile(callbackId: String, payload: String?) {
        guard let path = payload else {
            callbackJavascript(callbackId: callbackId, error: "不能打开文件")
            return
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let fileUrl = URL(fileURLWithPath: path)
            let fileName = fileUrl.lastPathComponent
            let dir = fileUrl.deletingLastPathComponent().path
            setLastArticlePath(fileName: fileName, filePath: path, relativePath: dir)
            handleMarkdownContent(callbackId: callbackId, payload: content)
        } catch {
            callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
        }
    }
    
    /// editor paste and drop
    func handleMarkdownContent(callbackId: String, payload: String?) {
        guard let content = payload else {
            callbackJavascript(callbackId: callbackId, data: "")
            return
        }
        guard let settings = getSettings() else {
            callbackJavascript(callbackId: callbackId, data: content)
            return
        }
        let autoUploadLocal = settings.uploadSettings.autoUploadLocal
        let autoUploadNetwork = settings.uploadSettings.autoUploadNetwork
        var uploadErrors: [String] = []
        Task { [weak self] in
            guard let self = self else { return }
            let _result = await uploadAndReplaceImagesInMarkdown(markdown: content) { src in
                guard autoUploadLocal == true else { return false }
                return !src.starts(with: "http")
            }
            uploadErrors.append(contentsOf: _result.errors)
            let result = await uploadAndReplaceImagesInMarkdown(markdown: _result.text) { src in
                guard autoUploadNetwork == true else { return false }
                return src.starts(with: "http") && !src.starts(with: "https://mmbiz.qpic.cn")
            }
            uploadErrors.append(contentsOf: result.errors)
            self.callbackJavascript(callbackId: callbackId, data: result.text)
            if !uploadErrors.isEmpty {
                self.dispatch(.onError(uploadErrors.joined(separator: "\n")))
            }
        }
    }
}

// MARK: - Image Handlers
extension MainViewModel {
    func pathToBase64(callbackId: String, payload: String?) {
        guard let path = payload?.trimmingCharacters(in: .whitespaces), !path.isEmpty else {
            callbackJavascript(callbackId: callbackId, error: "图片路径为空")
            return
        }
        
        let isNetwork = path.lowercased().hasPrefix("http://") || path.lowercased().hasPrefix("https://")
        let cacheKey: String
        var localFileURL: URL? = nil
        
        if isNetwork {
            // 1. 网络图片：直接以 URL 字符串作为缓存的 Key
            cacheKey = path
        } else if path.lowercased().hasPrefix("data:") {
            // 2. 已经是 Base64 的图片：直接原路返回，无需处理和缓存
            callbackJavascript(callbackId: callbackId, data: path)
            return
        } else {
            // 3. 本地图片：解析相对/绝对路径
            if (path as NSString).isAbsolutePath {
                localFileURL = URL(fileURLWithPath: path).standardizedFileURL
            } else {
                guard let articleDir = getLastArticleRelativePath(), !articleDir.isEmpty else {
                    // 相对路径但无法获取基准目录时，原路返回给前端兜底
                    callbackJavascript(callbackId: callbackId, data: path)
                    return
                }
                let baseURL = URL(fileURLWithPath: articleDir)
                let directoryURL = baseURL.hasDirectoryPath ? baseURL : baseURL.deletingLastPathComponent()
                localFileURL = directoryURL.appendingPathComponent(path).standardizedFileURL
            }
            // 本地图片以绝对路径作为缓存的 Key
            cacheKey = localFileURL!.path
        }
        
        // 统一查询缓存
        if let cached = imageLocalCache.get(cacheKey), !cached.isEmpty {
            callbackJavascript(callbackId: callbackId, data: cached)
            return
        }
        
        // 缓存未命中：启动后台任务异步下载或读取文件
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let base64URI: String
                
                if isNetwork {
                    // --- 处理网络图片 ---
                    guard let url = URL(string: path) else {
                        throw AppError.bizError(description: "无效的网络图片链接")
                    }
                    
                    // 异步下载图片数据
                    let (data, response) = try await URLSession.shared.data(from: url)
                    
                    // 校验 HTTP 状态码
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        throw AppError.bizError(description: "网络图片下载失败")
                    }
                    
                    // 优先使用服务器返回的 MIME Type，获取不到则兜底
                    let mimeType = response.mimeType ?? "image/png"
                    base64URI = "data:\(mimeType);base64,\(data.base64EncodedString())"
                    
                } else {
                    // --- 处理本地图片 ---
                    guard let targetURL = localFileURL else {
                        throw AppError.bizError(description: "本地路径解析失败")
                    }
                    base64URI = try getDataURIFromFile(at: targetURL)
                }
                
                // 写入缓存
                self.imageLocalCache.set(cacheKey, value: base64URI)
                self.callbackJavascript(callbackId: callbackId, data: base64URI)
            } catch {
                self.callbackJavascript(callbackId: callbackId, error: "图片处理失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 前端送来的图片已转成 base64 字符串
    func resolveUploadBase64Image(callbackId: String, payload: Any?) {
        guard let dict = payload as? [String: Any], let data = dict["file"] as? String, let fileData = Data(base64Encoded: data) else {
            callbackJavascript(callbackId: callbackId, error: "上传图片失败：未找到图片")
            return
        }
        let fileName = dict["fileName"] as? String ?? "upload"
        let mimetype = dict["mimetype"] as? String ?? "image/png"
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await uploadImageWithCache(fileData: fileData, fileName: fileName, mimeType: mimetype)
                self.callbackJavascript(callbackId: callbackId, data: response.url)
            } catch {
                self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
            }
        }
    }
    
    /// 前端送来的是 src 后面的图片路径
    func resolveUploadImage(callbackId: String, payload: String?) {
        guard let dataString = payload else {
            callbackJavascript(callbackId: callbackId, error: "上传图片失败：无法找到图片路径")
            return
        }
        let relativePath = getLastArticleRelativePath()
        let resolvedSrc = resolveRelativePath(path: dataString, relative: relativePath)
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await uploadImageToWechat(from: resolvedSrc)
                self.callbackJavascript(callbackId: callbackId, data: response)
            } catch {
                self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
            }
        }
    }
    
    func resolvePublishArticleToDraft(callbackId: String, payload: Any?) {
        guard let dict = payload as? [String: Any] else {
            callbackJavascript(callbackId: callbackId, error: "不能发布文章")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let publishOptions = try JSONDecoder().decode(WechatPublishOptions.self, from: data)
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let mediaId = try await publishArticle(publishOptions)
                    self.callbackJavascript(callbackId: callbackId, data: mediaId)
                } catch {
                    self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
                }
            }
        } catch {
            callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
        }
    }
}

extension MainViewModel {
    func handleResetLastArticlePath() {
        resetLastArticlePath()
    }
    
    func handleOpenLink(payload: String?) {
        guard let urlString = payload, let url = URL(string: urlString) else {
            return
        }
        DispatchQueue.main.async {
            NSWorkspace.shared.open(url)
        }
    }
    
    func handleAutoCacheChange() {
        do {
            try clearUploadCache()
        } catch {
            dispatch(.onError(error.localizedDescription))
        }
    }
    
    func handleResetWechatAccessToken() {
        clearAllCachedTokens()
    }
    
    func handleSaveExportedFile(payload: Any?) {
        guard let dict = payload as? [String: Any],
              let fileType = dict["fileType"] as? String,
              let fileName = dict["fileName"] as? String,
              let base64String = dict["base64Data"] as? String,
              let data = Data(base64Encoded: base64String) else {
            dispatch(.onError("缺少导出参数或 Base64 解析失败"))
            return
        }
        // 切回主线程触发 SwiftUI 弹窗
        DispatchQueue.main.async {
            self.exportFileData = DataFile(data: data)
            self.exportDefaultFilename = fileName
            if fileType == "pdf" {
                self.exportContentType = .pdf
            } else {
                self.exportContentType = fileName.hasSuffix(".png") ? .png : .jpeg
            }
            // 触发弹窗
            self.isFileExporting = true
        }
    }
}

// MARK: - Dispatcher
extension MainViewModel {
    func dispatch(_ action: UserAction) {
        switch action {
        case .changePlatform(let platform):
            emitJavascript(event: "setPlatform", data: platform.rawValue)
        case .openSettings:
            emitJavascript(event: "openSettings")
        case .setContent(let content):
            emitJavascript(event: "setContent", data: content)
        case .toggleFileSidebar:
            emitJavascript(event: "toggleFileSidebar")
        case .onError(let error):
            emitJavascript(event: "onError", data: error)
        }
    }
}

// MARK: - UIDelegate
extension MainViewModel: WKUIDelegate {
    // 为方便调试，让SwiftUI模拟JS的alert方法
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = "JavaScript Alert"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }
}
