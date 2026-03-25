//
//  MainUI.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import SwiftUI
import WebKit

struct MainUI: NSViewRepresentable {
    @EnvironmentObject private var viewModel: MainViewModel

    func makeCoordinator() -> MainViewModel {
        viewModel
    }

    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController

        let schemeHandler = LocalSchemeHandler()
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "app")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        webView.uiDelegate = context.coordinator
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false

        // 注册 JS 通信接口
        userController.add(context.coordinator, name: "wenyanBridge")
        
        // 初始加载
        if let url = URL(string: "app://index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // 当 viewModel的 @Published 属性变化时更新网页内容
    }
}
