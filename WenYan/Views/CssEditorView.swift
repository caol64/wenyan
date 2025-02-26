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
    @Published var editorMode: EditorMode = .developer
    var customTheme: CustomTheme?
    
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
    func loadContent(customTheme: CustomTheme?, modelTheme: ThemeStyleWrapper?) {
        do {
            if let customTheme = customTheme {
                content = customTheme.content ?? ""
            } else {
                if let modelTheme = modelTheme {
                    content = modelTheme.themeType == .builtin ? try loadFileFromResource(path: modelTheme.themeStyle!.rawValue) : modelTheme.customTheme!.content ?? ""
                } else {
                    content = try loadFileFromResource(forResource: "themes/gzh_default", withExtension: "css")
                }
            }
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
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
    
    func showHideOverlay(_ showHelpBubble: Bool) {
        showHelpBubble ? showOverlay() : hideOverlay()
    }
    
    func showOverlay() {
        callJavascript(javascriptString: "showOverlay();")
    }
    
    func hideOverlay() {
        callJavascript(javascriptString: "hideOverlay();")
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
    
    func save() {
        do {
            if let customTheme = customTheme {
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
}
