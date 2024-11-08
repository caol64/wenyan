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
    @EnvironmentObject private var htmlViewModel: HtmlViewModel
    
    var body: some View {
        VStack {
            HStack {
                MarkdownView()
                    .frame(minWidth: 680, idealWidth: 680, minHeight: 800, idealHeight: 800)
                HtmlView()
                    .frame(minWidth: 680, idealWidth: 680, minHeight: 800, idealHeight: 800)
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
                                    isPresented: htmlViewModel.hasLongImageData,
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
                            ThemeListPopup()
                                .padding(.trailing, 24)
                                .padding(.top, 8)
                                .environment(\.colorScheme, .light)
                        }
                    }
                    .onAppear() {
                        Task {
                            htmlViewModel.fetchCustomThemes()
                        }
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
        .onReceive(htmlViewModel.$scrollFactor) { newScrollFactor in
            markdownViewModel.scroll(scrollFactor: newScrollFactor)
        }
        .onReceive(markdownViewModel.$scrollFactor) { newScrollFactor in
            htmlViewModel.scroll(scrollFactor: newScrollFactor)
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
        .sheet(isPresented: $appState.showSheet) {
            SheetView()
        }
    }
    
    struct SheetView: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject private var cssEditorViewModel: CssEditorViewModel
        @EnvironmentObject private var themePreviewViewModel: ThemePreviewViewModel
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        @EnvironmentObject private var appState: AppState
        
        var body: some View {
            HStack {
                CssEditorView(customTheme: htmlViewModel.selectedCustomTheme)
                    .frame(minWidth: 500, minHeight: 580)
                ThemePreviewView()
                    .frame(minWidth: 500, minHeight: 580)
            }
            .onReceive(cssEditorViewModel.$content) { content in
                themePreviewViewModel.onUpdate(css: content)
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    if htmlViewModel.selectedCustomTheme != nil {
                        Button(action: {
                            htmlViewModel.deleteCustomTheme()
                            dismiss()
                        }) {
                            Text("删除")
                                .foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        cssEditorViewModel.save()
                        htmlViewModel.fetchCustomThemes()
                        htmlViewModel.setTheme()
                        dismiss()
                    }
                }
            }
            .background(.white)
        }
    }
    
    struct ThemeListPopup: View {
        @State private var menuWidth: CGFloat = 220
        @State private var menuHeight: CGFloat = 240
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        @EnvironmentObject private var appState: AppState
        
        var body: some View {
            VStack {
                List {
                    ForEach(Platform.gzh.themes, id: \.self) { theme in
                        ThemeListView(theme: ThemeStyleWrapper(themeType: .builtin, themeStyle: theme))
                    }
                    ForEach(htmlViewModel.customThemes, id: \.self) { theme in
                        CustomThemeListView(theme: ThemeStyleWrapper(themeType: .custom, customTheme: theme))
                    }
                    if htmlViewModel.customThemes.count < 3 {
                        HStack {
                            Spacer()
                            Text("创建新主题")
                            Button {
                                htmlViewModel.selectedCustomTheme = nil
                                appState.showSheet = true
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(Color.accentColor)
                        }
                        .padding(.trailing, 5)
                        .padding(.vertical, 2)
                    }
                }
                .padding(5)
                .listStyle(.plain)
                .background(Color.clear)
                .frame(width: menuWidth, height: menuHeight)
            }
            .frame(width: menuWidth, height: menuHeight)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .padding(8)
            .onReceive(htmlViewModel.$gzhTheme) { _ in
                htmlViewModel.changeTheme()
            }
            .onAppear() {
                calcHeight()
            }
            .onReceive(htmlViewModel.$customThemes) { _ in
                calcHeight()
            }
        }
        
        private func calcHeight() {
            menuHeight = 240 + CGFloat(min(htmlViewModel.customThemes.count, 2) * 28)
        }
        
    }
    
    struct ThemeListView: View {
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        @EnvironmentObject private var appState: AppState
        var theme: ThemeStyleWrapper
        
        var body: some View {
            Button(action: {
                htmlViewModel.gzhTheme = theme
            }) {
                HStack {
                    Text(theme.name())
                    Spacer()
                    Text(theme.author())
                }
                .foregroundColor(htmlViewModel.gzhTheme == theme ? Color.white : Color.primary)
                .contentShape(Rectangle())
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            .buttonStyle(.borderless)
            .background(htmlViewModel.gzhTheme == theme ? Color.accentColor : Color.clear)
        }
    }
    
    struct CustomThemeListView: View {
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        let theme: ThemeStyleWrapper
        
        var body: some View {
            HStack {
                Button(action: {
                    htmlViewModel.gzhTheme = theme
                }) {
                    HStack {
                        Text(theme.name())
                        Spacer()
                    }
                }
                .buttonStyle(.borderless)
                .padding(.leading, 5)
                .padding(.vertical, 2)
                .foregroundColor(htmlViewModel.gzhTheme == theme ? Color.white : Color.primary)
                
                HStack {
                    Button {
                        htmlViewModel.gzhTheme = theme
                        htmlViewModel.selectedCustomTheme = theme.customTheme
                        appState.showSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(htmlViewModel.gzhTheme == theme ? Color.white : Color.accentColor)
                }
                .padding(.vertical, 2)
                .padding(.trailing, 5)
            }
            .background(htmlViewModel.gzhTheme == theme ? Color.accentColor : Color.clear)
            .contentShape(Rectangle())
        }
    }
    
}
