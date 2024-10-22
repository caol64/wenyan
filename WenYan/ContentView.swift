//
//  ContentView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var markdownViewModel: MarkdownViewModel
    @StateObject private var htmlViewModel: HtmlViewModel
    @ObservedObject private var appState: AppState
    
    init(appState: AppState) {
        _markdownViewModel = StateObject(wrappedValue: MarkdownViewModel(appState: appState))
        _htmlViewModel = StateObject(wrappedValue: HtmlViewModel(appState: appState))
        self.appState = appState
    }

    var body: some View {
        VStack {
            HStack {
                MarkdownView(viewModel: markdownViewModel)
                    .frame(minWidth: 500, minHeight: 580)
                    .onReceive(htmlViewModel.$scrollFactor) { newScrollFactor in
                        markdownViewModel.scroll(scrollFactor: newScrollFactor)
                    }
                HtmlView(viewModel: htmlViewModel)
                    .frame(minWidth: 500, minHeight: 580)
                    .overlay(alignment: .topTrailing) {
                        VStack {
                            if htmlViewModel.platform == .gzh {
                                Button(action: {
                                    appState.showThemeList = true
                                }) {
                                    HStack {
                                        Image(systemName: "tshirt")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                        Text("主题")
                                            .font(.system(size: 14))
                                    }
                                    .frame(height: 24)
                                }
                                
                            }
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
                                htmlViewModel.changeFootnotes()
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
                            if htmlViewModel.platform == .gzh {
                                Button(action: {
                                    htmlViewModel.showFileExporter = true
                                    htmlViewModel.exportLongImage()
                                }) {
                                    HStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                        Text("长图")
                                            .font(.system(size: 14))
                                    }
                                    .frame(height: 24)
                                }
                                .fileExporter(
                                    isPresented: $htmlViewModel.showFileExporter,
                                    document: htmlViewModel.longImageData,
                                    contentType: .jpeg,
                                    defaultFilename: "out"
                                ) { result in
                                    switch result {
                                    case .success(let url):
                                        print("File saved to \(url)")
                                    case .failure(let error):
                                        appState.appError = AppError.bizError(description: error.localizedDescription)
                                    }
                                    htmlViewModel.longImageData = nil
                                }
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
                    .overlay(alignment: .topTrailing) {
                        if appState.showThemeList {
                            ThemeListPopup(htmlViewModel: htmlViewModel)
                                .padding(.trailing, 24)
                                .padding(.top, 8)
                                .environment(\.colorScheme, .light)
                        }
                    }
                    .onReceive(markdownViewModel.$scrollFactor) { newScrollFactor in
                        htmlViewModel.scroll(scrollFactor: newScrollFactor)
                    }
            }
            .background(.white)
        }
        .onAppear() {
            Task {
                markdownViewModel.loadArticle()
                htmlViewModel.content = markdownViewModel.content
            }
        }
        .onReceive(markdownViewModel.$content) { newContent in
            htmlViewModel.content = newContent
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
    
    struct ThemeListPopup: View {
        var menuWidth: CGFloat = 200
        var menuHeight: CGFloat = 200
        @ObservedObject var htmlViewModel: HtmlViewModel
        
        var body: some View {
            VStack {
                List {
                    ForEach(Platform.gzh.themes, id: \.self) { theme in
                        Button(action: {
                            htmlViewModel.gzhTheme = theme
                        }) {
                            HStack {
                                Text(theme.name)
                                Spacer()
                                Text(theme.author)
                            }
                            .background(htmlViewModel.gzhTheme == theme ? Color.gray.opacity(0.3) : Color.clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(5)
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .frame(width: menuWidth, height: menuHeight)
                .onReceive(htmlViewModel.$gzhTheme) { _ in
                    htmlViewModel.changeTheme()
                }
            }
            .frame(width: menuWidth, height: menuHeight)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .padding(8)
        }
        
    }

}
