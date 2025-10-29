//
//  WenYanApp.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

@main
struct WenYanApp: App {

    @StateObject private var appState: AppState
    @StateObject private var markdownViewModel: MarkdownViewModel
    @StateObject private var htmlViewModel: HtmlViewModel
    @StateObject private var cssEditorViewModel: CssEditorViewModel
    @StateObject private var cssPreviewViewModel: CssPreviewViewModel
    @StateObject private var codeblockSettingsViewModel: CodeblockSettingsViewModel
    @StateObject private var paragraphSettingsViewModel: ParagraphSettingsViewModel
    @State private var showFileImporter = false
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let appState = AppState()
        let markdownViewModel = MarkdownViewModel(appState: appState)
        let htmlViewModel = HtmlViewModel(appState: appState)
        let cssEditorViewModel = CssEditorViewModel(appState: appState)
        let cssPreviewViewModel = CssPreviewViewModel(appState: appState)
        let codeblockSettingsViewModel = CodeblockSettingsViewModel(htmlViewModel: htmlViewModel)
        let paragraphSettingsViewModel = ParagraphSettingsViewModel(htmlViewModel: htmlViewModel)
        markdownViewModel.bindTo(htmlViewModel)
        htmlViewModel.bind()
        htmlViewModel.bindTo(markdownViewModel)
        cssPreviewViewModel.bindTo(markdownViewModel)
        cssPreviewViewModel.bindTo(cssEditorViewModel)
        cssEditorViewModel.bindTo(cssPreviewViewModel)
        _appState = StateObject(wrappedValue: appState)
        _markdownViewModel = StateObject(wrappedValue: markdownViewModel)
        _htmlViewModel = StateObject(wrappedValue: htmlViewModel)
        _cssEditorViewModel = StateObject(wrappedValue: cssEditorViewModel)
        _cssPreviewViewModel = StateObject(wrappedValue: cssPreviewViewModel)
        _codeblockSettingsViewModel = StateObject(wrappedValue: codeblockSettingsViewModel)
        _paragraphSettingsViewModel = StateObject(wrappedValue: paragraphSettingsViewModel)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(markdownViewModel)
                .environmentObject(htmlViewModel)
                .environmentObject(cssEditorViewModel)
                .environmentObject(cssPreviewViewModel)
                .environmentObject(codeblockSettingsViewModel)
                .environmentObject(paragraphSettingsViewModel)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("关于\(getAppName())") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.version: ""
                        ]
                    )
                }
            }
            CommandGroup(replacing: .help) {
                if let helpURL = getAppinfo(for: "HelpUrl"), let url = URL(string: helpURL) {
                    Link("\(getAppName())使用帮助", destination: url)
                }
            }
            CommandGroup(after: .newItem) {
                Button("打开文件") {
                    showFileImporter = true
                }
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.md],
                    allowsMultipleSelection: false
                ) { result in
                    markdownViewModel.openArticle(result)
                }
                Button("打开示例文本") {
                    markdownViewModel.loadDefaultArticle()
                }
            }
        }

        SwiftUI.Settings {
            SettingsView()
                .environmentObject(codeblockSettingsViewModel)
                .environmentObject(paragraphSettingsViewModel)
        }
    }

}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.delegate = self
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }
}
