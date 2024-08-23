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
    
    func setContent() {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }
    
    func getContent(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getContent();", callback: block)
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }

}
