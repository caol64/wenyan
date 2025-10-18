//
//  CssEditorView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/10/23.
//

import SwiftUI
import WebKit

struct CssEditorView: NSViewRepresentable {
    @EnvironmentObject var viewModel: CssEditorViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
//        if #available(macOS 13.3, *) {
//            webView.isInspectable = true
//        }
        viewModel.setupWebView(webView)
        viewModel.loadIndex()
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {

    }
    
}

class CssEditorViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler, ObservableObject {
    var appState: AppState
    weak var webView: WKWebView?
    @Published var content: String = ""
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // 初始化 WebView
    func setupWebView(_ webView: WKWebView) {
        webView.navigationDelegate = self
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: WebkitStatus.loadHandler)
        contentController.add(self, name: WebkitStatus.contentChangeHandler)
        contentController.add(self, name: WebkitStatus.clickHandler)
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false
        self.webView = webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自 JavaScript 的消息
        if message.name == WebkitStatus.loadHandler {
            configWebView()
        } else if message.name == WebkitStatus.contentChangeHandler {
            content = (message.body as? String) ?? ""
        } else if message.name == WebkitStatus.clickHandler {
            if appState.showHelpBubble {
                appState.showHelpBubble = false
            }
        }
    }
    
}

extension CssEditorViewModel {    
    func configWebView() {
        setContent()
    }
    
    func loadIndex() {
        do {
            let html = try loadFileFromResource(forResource: "codemirror/css_editor", withExtension: "html")
            webView?.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func setContent() {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }
    
    func loadCss(css: String) {
        callJavascript(javascriptString: "loadCss(\(css.toJavaScriptString()));")
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
}
