//
//  HtmlView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import WebKit

struct HtmlView: NSViewRepresentable {
    let viewModel: HtmlViewModel
    
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

@Observable
class HtmlViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var appState: AppState
    var content: String = ""
    weak var webView: WKWebView?
    var previewMode: PreviewMode = .mobile
    var platform: Platform = .gzh
    var highlightStyle: HighlightStyle = .github
    var scrollFactor: CGFloat = 0
    var isCopied = false
    var isFootnotes = false
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // 初始化 WebView
    func setupWebView(_ webView: WKWebView) {
        webView.navigationDelegate = self
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: WebkitStatus.loadHandler)
        contentController.add(self, name: WebkitStatus.scrollHandler)
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
        }
    }
}

extension HtmlViewModel {
    func configWebView() {
        setPreviewMode()
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
    
    func getContentWithMathSvg(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContentWithMathSvg();", callback: block)
    }
    
    func setPreviewMode() {
        callJavascript(javascriptString: "setPreviewMode(\"\(previewMode.rawValue)\");")
    }
    
    func setTheme() {
        callJavascript(javascriptString: "setTheme(\"\(platform.themes[0].rawValue)\");")
    }
    
    func setHighlight() {
        callJavascript(javascriptString: "setHighlight(\"\(highlightStyle.rawValue)\");")
    }
    
    func removeHighlight() {
        callJavascript(javascriptString: "setHighlight(null);")
    }
    
    func scroll(scrollFactor: CGFloat) {
        callJavascript(javascriptString: "scroll(\(scrollFactor));")
    }
    
    func addFootnotes() {
        if (isFootnotes) {
            callJavascript(javascriptString: "addFootnotes();")
        } else {
            setContent()
        }
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
            fetchContent = getContentWithMathSvg
        case .zhihu:
            fetchContent = getContentWithMathImg
        case .juejin:
            fetchContent = getPostprocessMarkdown
        default:
            fetchContent = getContent
        }
        fetchContent { result in
            do {
                var content = try result.get() as! String
                if self.platform == .gzh {
                    let theme = try loadFileFromResource(path: self.platform.themes[0].rawValue)
                    let highlight = try loadFileFromResource(path: self.highlightStyle.rawValue)
                    content = "\(content)<style>\(theme)\(highlight)</style>"
                }

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
        self.platform = platform
        setTheme()
        if (platform == .zhihu) {
            removeHighlight()
        } else {
            setHighlight()
        }
    }

}
