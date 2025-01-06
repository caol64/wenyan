//
//  HtmlView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import WebKit

struct HtmlView: NSViewRepresentable {
    @EnvironmentObject var viewModel: HtmlViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
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
    @Published var highlightStyle: HighlightStyle = .github
    @Published var scrollFactor: CGFloat = 0
    @Published var isCopied = false
    @Published var isFootnotes = false
    @Published var gzhTheme: ThemeStyleWrapper = ThemeStyleWrapper(themeType: .builtin, themeStyle: Platform.gzh.themes[0])
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
    var selectedCustomTheme: CustomTheme?
    
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
            configWebView()
        } else if message.name == WebkitStatus.scrollHandler {
            guard let body = message.body as? [String: CGFloat], let y = body["y0"] else { return }
            scrollFactor = y
        } else if message.name == WebkitStatus.clickHandler {
            if appState.showThemeList {
                appState.showThemeList = false
            }
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
                    let themeStyle = ThemeStyle(rawValue: themeId) ?? platform.themes[0]
                    gzhTheme = ThemeStyleWrapper(themeType: .builtin, themeStyle: themeStyle)
                }
            }
        }
        setTheme()
        setHighlight()
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
    
    func getContentForGzh(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContentForGzh();", callback: block)
    }
    
    func getContentForMedium(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContentForMedium();", callback: block)
    }
    
    func getScrollFrame(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getScrollFrame();", callback: block)
    }
    
    func setPreviewMode() {
        callJavascript(javascriptString: "setPreviewMode(\"\(previewMode.rawValue)\");")
    }
    
    func setTheme() {
        do {
            if platform == .gzh {
                if gzhTheme.themeType == .custom {
                    if let customTheme = getCustomThemeById(id: gzhTheme.id().replacingOccurrences(of: "custom/", with: "")) {
                        callJavascript(javascriptString: "setCustomTheme(\(customTheme.content!.toJavaScriptString()));")
                    }
                } else {
                    let themeContent = try loadFileFromResource(path: gzhTheme.themeStyle!.rawValue)
                    callJavascript(javascriptString: "setCustomTheme(\(themeContent.toJavaScriptString()));")
                }
            } else {
                let themeContent = try loadFileFromResource(path: platform.themes[0].rawValue)
                callJavascript(javascriptString: "setCustomTheme(\(themeContent.toJavaScriptString()));")
            }
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func setHighlight() {
        do {
            let themeContent = try loadFileFromResource(path: highlightStyle.rawValue)
            callJavascript(javascriptString: "setHighlight(\(themeContent.toJavaScriptString()));")
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func removeHighlight() {
        callJavascript(javascriptString: "setHighlight(null);")
    }
    
    func scroll(scrollFactor: CGFloat) {
        callJavascript(javascriptString: "scroll(\(scrollFactor));")
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
        let fetchContent: (@escaping JavascriptCallback) -> Void
        switch self.platform {
        case .gzh:
            fetchContent = getContentForGzh
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
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.isCopied = false
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
        onUpdate()
        setTheme()
        if (platform == .zhihu) {
            removeHighlight()
        } else {
            setHighlight()
        }
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
                      let width = body["width"],
                      let height = body["height"]
                else {
                    return
                }
                
                let originalFrame = webView.frame
                let frameWidth = originalFrame.width - 30
                let clipWidth = width + 15
                let newFrame = NSRect(x: 0, y: 0, width: originalFrame.width, height: height)
                webView.frame = newFrame
                let configuration = WKSnapshotConfiguration()
                configuration.rect = NSRect(x: (frameWidth - width) / 2.0, y: 0, width: clipWidth, height: height)
                webView.takeSnapshot(with: configuration) { image, error in
                    if let image = image {
                        guard let tiffData = image.tiffRepresentation,
                              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
                            return
                        }
                        let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) // 设置压缩系数为 0.9
                        if let data = jpegData {
                            self.longImageData = DataFile(data: data)
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
        if let customTheme = selectedCustomTheme {
            do {
                try CoreDataStack.shared.delete(item: customTheme)
                selectedCustomTheme = nil
                fetchCustomThemes()
            } catch {
                self.appState.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
        gzhTheme = ThemeStyleWrapper(themeType: .builtin, themeStyle: Platform.gzh.themes[0])
    }
    
    func getCustomThemeById(id: String) -> CustomTheme? {
        return customThemes.filter { item in
            item.objectID.uriRepresentation().absoluteString == id
        }.first
    }
    
}
