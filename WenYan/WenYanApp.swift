//
//  WenYanApp.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import SwiftData

@main
struct WenYanApp: App {
    
    @StateObject private var appState: AppState
    @StateObject private var markdownViewModel: MarkdownViewModel
    @StateObject private var htmlViewModel: HtmlViewModel
    @StateObject private var cssEditorViewModel: CssEditorViewModel
    @StateObject private var themePreviewViewModel: ThemePreviewViewModel
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _markdownViewModel = StateObject(wrappedValue: MarkdownViewModel(appState: appState))
        _htmlViewModel = StateObject(wrappedValue: HtmlViewModel(appState: appState))
        _cssEditorViewModel = StateObject(wrappedValue: CssEditorViewModel(appState: appState))
        _themePreviewViewModel = StateObject(wrappedValue: ThemePreviewViewModel(appState: appState))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(markdownViewModel)
                .environmentObject(htmlViewModel)
                .environmentObject(cssEditorViewModel)
                .environmentObject(themePreviewViewModel)
                .alert(isPresented: appState.showError, error: appState.appError) {}
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About 文颜") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: str(),
                            NSApplication.AboutPanelOptionKey(
                                rawValue: "Copyright"
                            ): "© 2024 Lei Cao. All rights reserved."
                        ]
                    )
                }
            }
        }
    }
    
    func str() -> NSMutableAttributedString {
        let contactInfo = "问题反馈：support@yuzhi.tech"
        let email = "support@yuzhi.tech"

        // 创建一个可变的富文本字符串
        let attributedString = NSMutableAttributedString(
            string: contactInfo,
            attributes: [
                .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
            ]
        )

        // 获取 email 在字符串中的范围
        let emailRange = (contactInfo as NSString).range(of: email)

        // 设置 email 为可点击链接
        attributedString.addAttribute(.link, value: "mailto:\(email)", range: emailRange)
        return attributedString
    }
}
