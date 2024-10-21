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
    
    @ObservedObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
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
