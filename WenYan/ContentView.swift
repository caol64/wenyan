//
//  ContentView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    
    @State private var markdownViewModel: MarkdownViewModel
    @State private var htmlViewModel: HtmlViewModel
    
    init(appState: AppState) {
        _markdownViewModel = State(initialValue: MarkdownViewModel(appState: appState))
        _htmlViewModel = State(initialValue: HtmlViewModel(appState: appState))
    }

    var body: some View {
        VStack {
            HStack {
                MarkdownView(viewModel: markdownViewModel)
                    .frame(minWidth: 400, minHeight: 580)
                    .onChange(of: htmlViewModel.scrollFactor) {
                        markdownViewModel.scroll(scrollFactor: htmlViewModel.scrollFactor)
                    }
                HtmlView(viewModel: htmlViewModel)
                    .frame(minWidth: 400, minHeight: 580)
                    .overlay(alignment: .topTrailing) {
                        VStack {
                            Button("预览", systemImage: htmlViewModel.previewMode == .mobile ? "iphone.gen1" : "desktopcomputer") {
                                htmlViewModel.changePreviewMode()
                            }
                            Button("复制", systemImage: htmlViewModel.isCopied ? "checkmark" : "clipboard") {
                                htmlViewModel.onCopy()
                            }
                        }
                        .padding(.trailing, 32)
                        .padding(.top, 16)
                        .environment(\.colorScheme, .light)
                    }
                    .onChange(of: markdownViewModel.scrollFactor) {
                        htmlViewModel.scroll(scrollFactor: markdownViewModel.scrollFactor)
                    }
            }
            .background(.white)
        }
        .onAppear() {
            htmlViewModel.content = markdownViewModel.content
        }
        .onChange(of: markdownViewModel.content) {
            htmlViewModel.content = markdownViewModel.content
            htmlViewModel.onUpdate()
        }
        .toolbar() {
            ToolbarItemGroup {
                ForEach(Platform.allCases) { platform in
                    Button {
                        htmlViewModel.changePlatform(platform)
                    } label: {
                        Image(platform.rawValue)
                    }
                }
            }
        }
        .navigationTitle("文颜")
    }

}
