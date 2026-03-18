//
//  MainViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import WebKit

@MainActor
final class MainViewModel: NSObject, ObservableObject {
    
    private let appState: AppState
    weak var webView: WKWebView?
    @Published var content: String = ""
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - WebView Interaction

}

// MARK: - UIDelegate
extension MainViewModel: WKUIDelegate {
    // 为方便调试，让SwiftUI模拟JS的alert方法
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = "JavaScript Alert"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }
}
