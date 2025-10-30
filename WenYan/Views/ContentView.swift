//
//  ContentView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var markdownViewModel: MarkdownViewModel
    @State private var visibility: NavigationSplitViewVisibility = .detailOnly

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(minWidth: 150)
        } detail: {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    MarkdownView()
                    HtmlView()
                        .overlay(alignment: .topTrailing) {
                            if !appState.showInspector {
                                ToolButtonPopup()
                            }
                        }
                }
                .layoutPriority(1)
                .animation(.easeInOut(duration: 0.25), value: appState.showInspector)

                if appState.showInspector {
                    ThemeInspector()
                        .frame(width: 280)
                }
            }
        }
        .frame(minWidth: 1140, idealWidth: .infinity, minHeight: 645, idealHeight: .infinity)
        .toolbar {
            ToolbarItemGroup {
                ForEach(Platform.allCases) { platform in
                    Button {
                        appState.dispatch(.changePlatform(platform))
                    } label: {
                        Image(platform.rawValue)
                    }
                }
            }
        }
        .navigationTitle(getAppName())
        .background(Color(NSColor.windowBackgroundColor))
        .alert(isPresented: appState.showError, error: appState.appError) {}
        .task {
            markdownViewModel.loadArticle()
        }
        .sheet(isPresented: $appState.showSheet) {
            SheetView()
        }
    }

    struct SheetView: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject private var cssEditorViewModel: CssEditorViewModel
        @EnvironmentObject private var appState: AppState
        @State private var showFileImporter = false

        var body: some View {
            HStack {
                CssPreviewView()
                CssEditorView()
            }
            .layoutPriority(1)
            .frame(minWidth: 1040, idealWidth: 1280, minHeight: 580, idealHeight: 680)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if appState.showDeleteButton {
                        Button(action: {
                            appState.dispatch(.deleteCustomTheme)
                            dismiss()
                        }) {
                            Text("删除")
                                .foregroundColor(.red)
                        }
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button("导入") {
                        showFileImporter = true
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        if let url = URL(string: "https://babyno.top/posts/2024/11/wenyan-supports-customized-themes/") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label("", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.borderless)
                    .font(.system(size: 13))
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        appState.dispatch(.saveCustomTheme(cssEditorViewModel.content))
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.css],
                allowsMultipleSelection: false
            ) { result in
                cssEditorViewModel.loadCssFromFile(result)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }

    }
}
