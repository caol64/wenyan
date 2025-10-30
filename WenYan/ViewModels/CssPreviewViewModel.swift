//
//  CssPreviewViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/29.
//

import Combine
import SwiftUI
import WebKit

@MainActor
final class CssPreviewViewModel: NSObject, ObservableObject {
    private let appState: AppState
    @Published var content: String = ""
    @Published var themeContent = ""  // 从js获取的内置主题css
    weak var webView: WKWebView?
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Combine Subscriber
    func bindTo(_ markdownViewModel: MarkdownViewModel) {
        markdownViewModel.$content
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.content = newContent
            }
            .store(in: &cancellables)
    }
    
    func bindTo(_ cssEditorViewModel: CssEditorViewModel) {
        cssEditorViewModel.$content
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.setCustomTheme(themeContent: newContent)
            }
            .store(in: &cancellables)
    }

    // MARK: - WebView Interaction
    func loadInitialHTML(in webView: WKWebView) {
        do {
            let html = try loadFileFromResource(forResource: "preview", withExtension: "html")
            webView.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            error.handle(in: appState)
        }
    }

    func setContentToWebView() {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }
    
    func getThemeById() {
        callJavascript(javascriptString: "getThemeById(\(appState.gzhTheme.id().toJavaScriptString()));")
    }
    
    func configWebView() {
        setContentToWebView()
    }
    
    func setCustomTheme(themeContent: String) {
        callJavascript(javascriptString: "setCustomTheme(\(themeContent.toJavaScriptString()), false);")
    }
    
    func getThemeContent() {
        if appState.gzhTheme.themeType == .builtin {
            getThemeById()
        } else {
            themeContent = appState.gzhTheme.customTheme?.content ?? ""
        }
    }

    // MARK: - Call Javascript
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
}

// MARK: - ScriptMessageHandler
extension CssPreviewViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        // 处理来自 JavaScript 的消息
        case WebkitStatus.loadHandler:  // wenyan-core.js 初始化完毕
            configWebView()
            getThemeContent()
        case WebkitStatus.loadThemesHandler:
            guard let body = message.body as? String else { return }
            themeContent = body
            setCustomTheme(themeContent: themeContent)
        default:
            break
        }
    }
}
