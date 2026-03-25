//
//  MainViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import WebKit

@MainActor
final class MainViewModel: NSObject, ObservableObject {
    
    private let appState: AppState
    weak var webView: WKWebView?
    private let cache = FIFOCache<String, String>(max: 50)
    
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
        case "loadArticle":
            handleLoadArticle(callbackId: callbackId)
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
        case "localPathToBase64":
            localPathToBase64(callbackId: callbackId, payload: payload as? String)
        case "uploadBase64Image":
            resolveUploadBase64Image(callbackId: callbackId, payload: payload)
        case "handleMarkdownContent":
            handleMarkdownContent(callbackId: callbackId, payload: payload as? String)
        case "uploadImage":
            resolveUploadImage(callbackId: callbackId, payload: payload as? String)
        case "resetLastArticlePath":
            resetLastArticlePath()
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
    
    func handleLoadArticle(callbackId: String) {
        if let article = loadArticle() {
            callbackJavascript(callbackId: callbackId, data: article)
        } else {
            do {
                let content = try loadFileFromResource(forResource: "example", withExtension: "md")
                callbackJavascript(callbackId: callbackId, data: content)
            } catch {
                callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
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
        if let dict = payload as? [String: Any] {
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
    }
    
    func handleRemoveTheme(payload: String?) {
        do {
            if let idToDelete = payload {
                if let theme = try getCustomThemeById(id: idToDelete) {
                    try deleteCustomTheme(theme)
                }
            }
        } catch {
            error.handle(in: appState)
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
        Task { [weak self] in
            guard let self = self else { return }
            if let path = payload {
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
    }
    
    /// open file
    func handleMarkdownFile(callbackId: String, payload: String?) {
        if let path = payload {
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
    }
}

// MARK: - Image Handlers
extension MainViewModel {
    func localPathToBase64(callbackId: String, payload: String?) {
        guard let path = payload, !path.trimmingCharacters(in: .whitespaces).isEmpty else {
            callbackJavascript(callbackId: callbackId, error: "Image path is empty")
            return
        }
        let cleanPath = path.trimmingCharacters(in: .whitespaces)
        
        if let cached = cache.get(cleanPath), !cached.isEmpty {
            callbackJavascript(callbackId: callbackId, data: cached)
            return
        }
        
        if cleanPath.lowercased().hasPrefix("http") {
            callbackJavascript(callbackId: callbackId, data: cleanPath)
            return
        }
        
        func processFileURL(_ fileURL: URL) {
            // 异步读取文件，避免主线程卡顿
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    guard let base64 = try getDataURIFromFile(at: fileURL) else {
                        self.callbackJavascript(callbackId: callbackId, error: "Failed to convert file to Base64: \(fileURL.path)")
                        return
                    }
                    
                    self.cache.set(cleanPath, value: base64)
                    self.callbackJavascript(callbackId: callbackId, data: base64)
                } catch {
                    self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
                }
            }
        }
        
        // 绝对路径处理
        if (cleanPath as NSString).isAbsolutePath {
            processFileURL(URL(fileURLWithPath: cleanPath))
            return
        }
        
        // 相对路径处理
        guard let relativePath = getLastArticleRelativePath(), !relativePath.isEmpty else {
            callbackJavascript(callbackId: callbackId, data: cleanPath)
            return
        }
        
        let baseURL = URL(fileURLWithPath: relativePath)
        let resolvedURL = baseURL.appendingPathComponent(cleanPath).standardized
        processFileURL(resolvedURL)
    }
    
    func resolveUploadBase64Image(callbackId: String, payload: Any?) {
        if let dict = payload as? [String: Any], let data = dict["file"] as? String, let fileData = Data(base64Encoded: data) {
            let fileName = dict["fileName"] as? String ?? "upload"
            let mimetype = dict["mimetype"] as? String ?? "application/octet-stream"
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let response = try await uploadImage(fileData: fileData, fileName: fileName, mimeType: mimetype)
                    let httpsUrl = response.url.replacingOccurrences(of: "http://", with: "https://")
                    self.callbackJavascript(callbackId: callbackId, data: httpsUrl)
                } catch {
                    self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
                }
            }
        } else {
            callbackJavascript(callbackId: callbackId, error: "上传图片失败：未找到图片")
        }
    }
    
    func resolveUploadImage(callbackId: String, payload: String?) {
        if let dataString = payload {
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let response = try await uploadImageToWechat(from: dataString)
                    let httpsUrl = response.url.replacingOccurrences(of: "http://", with: "https://")
                    self.callbackJavascript(callbackId: callbackId, data: httpsUrl)
                } catch {
                    self.callbackJavascript(callbackId: callbackId, error: error.localizedDescription)
                }
            }
        } else {
            callbackJavascript(callbackId: callbackId, error: "上传图片失败：无法找到图片路径")
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
