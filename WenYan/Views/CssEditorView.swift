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
    
    func makeCoordinator() -> CssEditorViewModel {
        viewModel
    }

    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        //        if #available(macOS 13.3, *) {
        //            webView.isInspectable = true
        //        }
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false

        // 注册 JS 通信接口
        userController.add(context.coordinator, name: WebkitStatus.loadHandler)
        userController.add(context.coordinator, name: WebkitStatus.contentChangeHandler)

        // 初始加载
        context.coordinator.loadInitialHTML(in: webView)
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // 当 viewModel的 @Published 属性变化时更新网页内容
    }
}
