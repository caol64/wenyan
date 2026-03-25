////
////  MarkdownView.swift
////  WenYan
////
////  Created by Lei Cao on 2024/8/19.
////
//
//import SwiftUI
//import WebKit
//
//struct MarkdownView: NSViewRepresentable {
//    @EnvironmentObject private var viewModel: MarkdownViewModel
//
//    func makeCoordinator() -> MarkdownViewModel {
//        viewModel
//    }
//
//    func makeNSView(context: Context) -> WKWebView {
//        let userController = WKUserContentController()
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userController
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        //        if #available(macOS 13.3, *) {
//        //            webView.isInspectable = true
//        //        }
//        webView.uiDelegate = context.coordinator
//        webView.setValue(true, forKey: "drawsTransparentBackground")
//        webView.allowsMagnification = false
//
//        // 注册 JS 通信接口
//        userController.add(context.coordinator, name: WebkitStatus.loadHandler)
//        userController.add(context.coordinator, name: WebkitStatus.contentChangeHandler)
//        userController.add(context.coordinator, name: WebkitStatus.scrollHandler)
//        userController.add(context.coordinator, name: WebkitStatus.errorHandler)
//        userController.add(context.coordinator, name: WebkitStatus.uploadHandler)
//
//        // 初始加载
//        context.coordinator.loadInitialHTML(in: webView)
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateNSView(_ webView: WKWebView, context: Context) {
//        // 当 viewModel的 @Published 属性变化时更新网页内容
//    }
//}
