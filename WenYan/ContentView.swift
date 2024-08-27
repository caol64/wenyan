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
                            Button(action: {
                                htmlViewModel.changePreviewMode()
                            }) {
                                HStack {
                                    Image(systemName: htmlViewModel.previewMode == .mobile ? "iphone.gen1" : "desktopcomputer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                    Text("预览")
                                        .font(.system(size: 14))
                                }
                                .frame(height: 24)
                            }
                            Button(action: {
                                htmlViewModel.isFootnotes.toggle()
                                htmlViewModel.addFootnotes()
                            }) {
                                HStack {
                                    Image(systemName: htmlViewModel.isFootnotes ? "link.circle.fill" : "link.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                    Text("脚注")
                                        .font(.system(size: 14))
                                }
                                .frame(height: 24)
                            }
                            Button(action: {
                                htmlViewModel.onCopy()
                            }) {
                                HStack {
                                    Image(systemName: htmlViewModel.isCopied ? "checkmark" : "clipboard")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                    Text("复制")
                                        .font(.system(size: 14))
                                }
                                .frame(height: 24)
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
            markdownViewModel.loadExampleArticle()
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
