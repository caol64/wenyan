//
//  MarkdownView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import WebKit

struct MarkdownView: NSViewRepresentable {
    let viewModel: MarkdownViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        viewModel.setupWebView(webView)
        viewModel.loadIndex()
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {

    }
    
}

@Observable
class MarkdownViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var appState: AppState
    var content: String = "# Marked in the browser\n\nRendered by **marked**."
    weak var webView: WKWebView?
    
    init(appState: AppState) {
        self.appState = appState
    }

    // 初始化 WebView
    func setupWebView(_ webView: WKWebView) {
        webView.navigationDelegate = self
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: WebkitStatus.isReady)
        contentController.add(self, name: WebkitStatus.textContentDidChange)
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false
        self.webView = webView
    }
    
    // WKNavigationDelegate 方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation")
    }
    
    // WKScriptMessageHandler 方法
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自 JavaScript 的消息
        if message.name == WebkitStatus.isReady {
            configWebView()
        } else if message.name == WebkitStatus.textContentDidChange {
            let content = (message.body as? String) ?? ""
            self.content = content
        }
    }
}

extension MarkdownViewModel {
    func configWebView() {
        setDefaultTheme()
        setTabInsertsSpaces(true)
        setFontSize(14)
        setContent()
    }
    
    func loadIndex() {
        do {
            let html = try loadFileFromResource(forResource: "codemirror/index", withExtension: "html")
            webView?.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func setTabInsertsSpaces(_ value: Bool) {
        callJavascript(javascriptString: "SetTabInsertSpaces(\(value));")
    }
    
    func setContent() {
        callJavascript(javascriptString: "SetContent(\(content.toJavaScriptString()));")
    }
    
    func getContent(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "GetContent();", callback: block)
    }
    
    func setMimeType(_ value: String) {
        callJavascript(javascriptString: "SetMimeType(\(value.toJavaScriptString()));")
    }
    
    func getMimeType(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "GetMimeType();", callback: block)
    }
    
    func setThemeName(_ value: String) {
        callJavascript(javascriptString: "SetTheme(\(value.toJavaScriptString()));")
    }
    
    func setLineWrapping(_ value: Bool) {
        callJavascript(javascriptString: "SetLineWrapping(\(value));")
    }
    
    func setFontSize(_ value: Int) {
        callJavascript(javascriptString: "SetFontSize(\(value));")
    }
    
    func setShowInvisibleCharacters(_ show: Bool) {
        callJavascript(javascriptString: "ToggleInvisible(\(show));")
    }
    
    func setDefaultTheme() {
        setMimeType("text/markdown")
    }
    
    func setReadonly(_ value: Bool) {
        callJavascript(javascriptString: "SetReadOnly(\(value));")
    }
    
    func getTextSelection(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "GetTextSelection();", callback: block)
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }

}
