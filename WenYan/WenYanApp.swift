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
    @StateObject private var mainViewModel: MainViewModel
    @State private var showFileImporter = false
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        let appState = AppState()
        let mainViewModel = MainViewModel(appState: appState)
        _appState = StateObject(wrappedValue: appState)
        _mainViewModel = StateObject(wrappedValue: mainViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(mainViewModel)
                .onAppear {
                    DispatchQueue.main.async {
                        if let window = NSApp.keyWindow ?? NSApp.windows.first,
                           let screen = window.screen ?? NSScreen.main {
                            window.setFrame(screen.visibleFrame, display: true, animate: true)
                        }
                    }
                }
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
                Button("打开示例文本") {
                    do {
                        let content = try loadFileFromResource(forResource: "example", withExtension: "md")
                        mainViewModel.dispatch(.setContent(content))
                    } catch {
                        mainViewModel.dispatch(.onError(error.localizedDescription))
                    }
                }
            }
            CommandGroup(replacing: .appSettings) {
                Button("设置...") {
                    mainViewModel.dispatch(.openSettings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
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
