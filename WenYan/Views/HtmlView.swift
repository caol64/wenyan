//
//  HtmlView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import WebKit
import PDFKit

struct HtmlView: NSViewRepresentable {
    @EnvironmentObject var viewModel: HtmlViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
//        if #available(macOS 13.3, *) {
//            webView.isInspectable = true
//        }
        viewModel.setupWebView(webView)
        viewModel.loadIndex()
        return webView
    }
    
    func updateNSView(_ uiView: WKWebView, context: Context) {
    }
}

class HtmlViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler, ObservableObject {
    var appState: AppState
    @Published var content: String = ""
    weak var webView: WKWebView?
    @Published var previewMode: PreviewMode = .mobile
    @Published var platform: Platform = .gzh
    @Published var scrollFactor: CGFloat = 0
    @Published var isFootnotes = false
    @Published var gzhTheme = ThemeStyleWrapper.getDefault()
    @Published var cssEditorContent = ""
    var codeblockSettings = CodeblockSettingsViewModel.loadSettings() ?? CodeblockSettings()
    @Published var longImageData: DataFile?
    var hasLongImageData: Binding<Bool> {
        Binding {
            self.longImageData != nil
        } set: {
            if !$0 {
                self.longImageData = nil
            }
        }
    }
    @Published var pdfData: DataFile?
    var hasPdfData: Binding<Bool> {
        Binding {
            self.pdfData != nil
        } set: {
            if !$0 {
                self.pdfData = nil
            }
        }
    }
    @Published var customThemes: [CustomTheme] = []
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // 初始化 WebView
    func setupWebView(_ webView: WKWebView) {
        webView.navigationDelegate = self
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: WebkitStatus.loadHandler)
        contentController.add(self, name: WebkitStatus.scrollHandler)
        contentController.add(self, name: WebkitStatus.clickHandler)
        contentController.add(self, name: WebkitStatus.loadThemesHandler)
        contentController.add(self, name: WebkitStatus.copyContentHandler)
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false
        self.webView = webView
    }
    
    // WKNavigationDelegate 方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        print("didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //        print("didFail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //        print("didFailProvisionalNavigation")
    }
    
    // WKScriptMessageHandler 方法
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自 JavaScript 的消息
        if message.name == WebkitStatus.loadHandler {
            if let body = message.body as? [String: [[String: String]]] {
                if let gzhThemes = body["gzhThemes"] {
                    PlatformConfig.setThemes(body: gzhThemes)
                }
                if let hlThemes = body["hlThemes"] {
                    HlThemeConfig.setThemes(body: hlThemes)
                }
            }
            configWebView()
        } else if message.name == WebkitStatus.scrollHandler {
            guard let body = message.body as? [String: CGFloat], let y = body["y0"] else { return }
            scrollFactor = y
        } else if message.name == WebkitStatus.clickHandler {
            if appState.showThemeList {
                appState.showThemeList = false
            }
        } else if message.name == WebkitStatus.loadThemesHandler {
            guard let body = message.body as? String else { return }
            cssEditorContent = body
        } else if message.name == WebkitStatus.copyContentHandler {
            guard let body = message.body as? String else { return }
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(body, forType: .html)
            appState.toggleCopyIcon()
        }
    }
}

extension HtmlViewModel {
    func configWebView() {
        setPreviewMode()
        if platform == .gzh {
            if let themeId = UserDefaults.standard.string(forKey: "gzhTheme") {
                if themeId.starts(with: "custom/") {
                    if let customTheme = getCustomThemeById(id: themeId.replacingOccurrences(of: "custom/", with: "")) {
                        gzhTheme = ThemeStyleWrapper(themeType: .custom, customTheme: customTheme)
                    }
                } else {
                    let themeStyle = Platform.gzh.theme(withId: themeId)
                    gzhTheme = ThemeStyleWrapper(themeType: .builtin, themeStyle: themeStyle)
                }
            }
            setParagraphSettings(paragraphSettings: ParagraphSettingsViewModel.loadSettings() ?? ParagraphSettings())
        }
        setCodeblock()
        setTheme()
        setContent()
    }
    
    func loadIndex() {
        do {
            let html = try loadFileFromResource(forResource: "index", withExtension: "html")
            webView?.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func setContent() {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }
    
    func getContent(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContent();", callback: block)
    }
    
    func getPostprocessMarkdown(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getPostprocessMarkdown();", callback: block)
    }
    
    func getContentWithMathImg(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContentWithMathImg();", callback: block)
    }
    
    func getContentForGzh() {
        callJavascript(javascriptString: "getContentForGzh();")
    }
    
    func getContentForMedium(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContentForMedium();", callback: block)
    }
    
    func getScrollFrame(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getScrollFrame();", callback: block)
    }
    
    func setPreviewMode() {
        callJavascript(javascriptString: "setPreviewMode(\(previewMode.rawValue.toJavaScriptString()));")
    }
    
    func getThemeById() {
        callJavascript(javascriptString: "getThemeById(\(gzhTheme.id().toJavaScriptString()));")
    }
    
    func setTheme() {
        if platform == .gzh {
            if gzhTheme.themeType == .custom,
               let customTheme = getCustomThemeById(id: gzhTheme.id().replacingOccurrences(of: "custom/", with: "")) {
                let themeContent = customTheme.content!
                callJavascript(javascriptString: "setCustomTheme(\(themeContent.toJavaScriptString()));")
            } else {
                callJavascript(javascriptString: "setThemeById(\(gzhTheme.id().toJavaScriptString()), true);")
            }
        } else {
            callJavascript(javascriptString: "setThemeById(\(platform.themes[0].id.toJavaScriptString()), false);")
        }
    }
    
    func scroll(scrollFactor: CGFloat) {
        callJavascript(javascriptString: "scroll(\(scrollFactor));")
    }
    
    func setParagraphSettings(paragraphSettings: ParagraphSettings) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(paragraphSettings)
            let jsonString = String(data: jsonData, encoding: .utf8)
            let jsString = jsonString ?? ""
            callJavascript(javascriptString: "setParagraphSettings(JSON.parse(\(jsString.toJavaScriptString())));")
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func changeFootnotes() {
        isFootnotes.toggle()
        if isFootnotes {
            addFootnotes()
        } else {
            removeFootnotes()
        }
    }
    
    func addFootnotes() {
        if platform == .gzh {
            callJavascript(javascriptString: "addFootnotes(false);")
        } else {
            callJavascript(javascriptString: "addFootnotes(true);")
        }
    }
    
    func removeFootnotes() {
        setContent()
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
    
    func onUpdate() {
        setContent()
        if (isFootnotes) {
            addFootnotes()
        }
    }
    
    func onCopy() {
        if self.platform == .gzh {
            getContentForGzh()
            return
        }
        let fetchContent: (@escaping JavascriptCallback) -> Void
        switch self.platform {
        case .zhihu:
            fetchContent = getContentWithMathImg
        case .juejin:
            fetchContent = getPostprocessMarkdown
        case .medium:
            fetchContent = getContentForMedium
        default:
            fetchContent = getContent
        }
        fetchContent { result in
            do {
                let content = try result.get() as! String
//                print(content)
                let pasteBoard = NSPasteboard.general
                pasteBoard.clearContents()
                if self.platform == .juejin {
                    pasteBoard.setString(content, forType: .string)
                } else {
                    pasteBoard.setString(content, forType: .html)
                }
                self.appState.toggleCopyIcon()
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
    }
    
    func changePreviewMode() {
        previewMode = (previewMode == .mobile) ? .desktop : .mobile
        setPreviewMode()
    }
    
    func changePlatform(_ platform: Platform) {
        if appState.showThemeList {
            appState.showThemeList = false
        }
        self.platform = platform
        if (platform == .gzh) {
            setParagraphSettings(paragraphSettings: ParagraphSettingsViewModel.loadSettings() ?? ParagraphSettings())
            setCodeblock()
        } else {
            callJavascript(javascriptString: "removeMacStyle();")
            callJavascript(javascriptString: "setHighlight('github');")
        }
        setTheme()
    }
    
    func changeTheme() {
        setTheme()
        Task {
            UserDefaults.standard.set(gzhTheme.id(), forKey: "gzhTheme")
        }
    }
    
    func exportLongImage() {
        guard let webView = self.webView else {
            return
        }
        getScrollFrame { result in
            do {
                guard let body = try result.get() as? [String: CGFloat],
                      let height = body["height"]
                else {
                    return
                }
                
                let originalFrame = webView.frame
                let newFrame = NSRect(x: 0, y: 0, width: originalFrame.width, height: height)
                webView.frame = newFrame
                webView.exportPDF() { pdfData, error in
                    if let data = pdfData, let pdf = PDFDocument(data: data), let page = pdf.page(at: 0) {
                        let image = page.thumbnail(of: CGSize(width: 1024, height: 1024 * CGFloat(page.bounds(for: .mediaBox).height / page.bounds(for: .mediaBox).width)), for: .mediaBox)
                        if let tiffData = image.tiffRepresentation,
                            let bitmapRep = NSBitmapImageRep(data: tiffData) {
                            let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
                            if let data = jpegData {
                                self.longImageData = DataFile(data: data)
                            }
                        }
                    }
                }
                webView.frame = originalFrame
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
    }
    
    func exportPDF() {
        guard let webView = self.webView else {
            return
        }
        getScrollFrame { result in
            do {
                guard let body = try result.get() as? [String: CGFloat],
                      let height = body["height"]
                else {
                    return
                }
                
                let originalFrame = webView.frame
                let newFrame = NSRect(x: 0, y: 0, width: originalFrame.width, height: height)
                webView.frame = newFrame
                webView.exportPDF() { pdfData, error in
                    if let pdfData = pdfData {
                        self.pdfData = DataFile(data: pdfData)
                    }
                }
                webView.frame = originalFrame
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
    }
    
    func fetchCustomThemes() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CustomTheme> = CustomTheme.fetchRequest()
        do {
            customThemes = try context.fetch(fetchRequest)
        } catch {
            self.appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func deleteCustomTheme() {
        if let customTheme = gzhTheme.customTheme {
            do {
                try CoreDataStack.shared.delete(item: customTheme)
                fetchCustomThemes()
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
        gzhTheme = ThemeStyleWrapper.getDefault()
    }
    
    func getCustomThemeById(id: String) -> CustomTheme? {
        return customThemes.filter { item in
            item.objectID.uriRepresentation().absoluteString == id
        }.first
    }
    
    func saveCustomTheme(content: String) {
        do {
            if let customTheme = gzhTheme.customTheme {
                customTheme.content = content
            } else {
                let context = CoreDataStack.shared.persistentContainer.viewContext
                let customTheme = CustomTheme(context: context)
                customTheme.name = "自定义主题"
                customTheme.content = content
                customTheme.createdAt = Date()
            }
            try CoreDataStack.shared.save()
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func setCodeblock() {
        if platform == .gzh {
            if codeblockSettings.isEnabled {
                callJavascript(javascriptString: "setHighlight(\(codeblockSettings.theme.toJavaScriptString()));")
                setCodeblockSettings(codeblockSettings: codeblockSettings)
                if codeblockSettings.isMacStyle {
                    callJavascript(javascriptString: "setMacStyle();")
                } else {
                    callJavascript(javascriptString: "removeMacStyle();")
                }
            } else {
                callJavascript(javascriptString: "setMacStyle();")
                callJavascript(javascriptString: "setHighlight('github');")
                setCodeblockSettings(codeblockSettings: CodeblockSettings())
            }
        }
    }
    
    func setCodeblockSettings(codeblockSettings: CodeblockSettings) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(codeblockSettings)
            let jsonString = String(data: jsonData, encoding: .utf8)
            let jsString = jsonString ?? ""
            callJavascript(javascriptString: "setCodeblockSettings(JSON.parse(\(jsString.toJavaScriptString())));")
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
}
