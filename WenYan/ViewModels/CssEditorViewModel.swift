//
//  CssEditorViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Combine
import SwiftUI
import WebKit

@MainActor
class CssEditorViewModel: NSObject, ObservableObject {
    private let appState: AppState
    @Published var content: String = ""
    weak var webView: WKWebView?
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Combine Subscriber
    func bindTo(_ cssPreviewViewModel: CssPreviewViewModel) {
        cssPreviewViewModel.$themeContent
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.setContentToWebView(content: newContent)
            }
            .store(in: &cancellables)
    }

    // MARK: - WebView Interaction
    func loadInitialHTML(in webView: WKWebView) {
        do {
            let html = try loadFileFromResource(forResource: "codemirror/css_editor", withExtension: "html")
            webView.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            error.handle(in: appState)
        }
    }

    func setContentToWebView(content: String) {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }

    func loadCss(css: String) {
        callJavascript(javascriptString: "loadCss(\(css.toJavaScriptString()));")
    }
    
    func loadCssFromFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let files):
            let file = files[0]
            let gotAccess = file.startAccessingSecurityScopedResource()
            if !gotAccess { return }
            do {
                loadCss(css: try String(contentsOfFile: file.path, encoding: .utf8))
            } catch {
                error.handle(in: appState)
            }
            file.stopAccessingSecurityScopedResource()
        case .failure(let error):
            error.handle(in: appState)
        }
    }

    // MARK: - Call Javascript
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }

}

// MARK: - ScriptMessageHandler
extension CssEditorViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        // 处理来自 JavaScript 的消息
        case WebkitStatus.loadHandler:  // codemirror初始化完毕
            setContentToWebView(content: content)
        case WebkitStatus.contentChangeHandler:  // codemirror内容变化
            content = (message.body as? String) ?? ""
        default:
            break
        }
    }
}
