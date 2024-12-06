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
    @State private var isMasking = false
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    MarkdownView()
                        .frame(minWidth: 680, idealWidth: 680, minHeight: 800, idealHeight: 800)
                    HtmlView()
                        .frame(minWidth: 680, idealWidth: 680, minHeight: 800, idealHeight: 800)
                        .overlay(alignment: .topTrailing) {
                            ToolButtonPopup()
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
                
                if #available(macOS 13.0, *) {
                    if isMasking {
                        Color.black.opacity(0)
                            .background(
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .dropDestination(for: URL.self) { items, _ in
                                        isMasking = false
                                        markdownViewModel.dragArticle(url: items[0])
                                        return true
                                    }
                            )
                            .zIndex(1)
                    }
                }
            }
        }
        .onHover { hovering in
            if #available(macOS 13.0, *) {
                if hovering {
                    withAnimation {
                        isMasking = NSEvent.pressedMouseButtons > 0
                    }
                } else {
                    withAnimation {
                        isMasking = true
                    }
                }
            }
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
        @State private var showFileImporter = false
        
        var body: some View {
            HStack {
                CssEditorView()
                    .frame(minWidth: 500, minHeight: 580)
                ThemePreviewView()
                    .frame(minWidth: 500, minHeight: 580)
            }
            .onReceive(cssEditorViewModel.$content) { content in
                themePreviewViewModel.onUpdate(css: content)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
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
                
                ToolbarItem(placement: .automatic) {
                    Button("导入") {
                        appState.showHelpBubble = false
                        showFileImporter = true
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("", systemImage: "questionmark.circle") {
                        appState.showHelpBubble.toggle()
                    }
                    .buttonStyle(.borderless)
                    .font(.system(size: 13))
                    .overlay(alignment: .bottomLeading) {
                        if appState.showHelpBubble {
                            HelpBubble()
                                .padding(.bottom, 20)
                                .environment(\.colorScheme, .light)
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        appState.showHelpBubble = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        appState.showHelpBubble = false
                        cssEditorViewModel.save()
                        htmlViewModel.fetchCustomThemes()
                        htmlViewModel.setTheme()
                        dismiss()
                    }
                }
            }
            .background(.white)
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.css],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    let file = files[0]
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    do {
                        cssEditorViewModel.loadCss(css: try String(contentsOfFile: file.path, encoding: .utf8))
                    } catch {
                        appState.appError = AppError.bizError(description: error.localizedDescription)
                    }
                    file.stopAccessingSecurityScopedResource()
                case .failure(let error):
                    appState.appError = AppError.bizError(description: error.localizedDescription)
                }
            }
        }
    }
    
    struct ToolButtonPopup: View {
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        @EnvironmentObject private var appState: AppState
        var body: some View {
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
    }
    
    struct ThemeListPopup: View {
        @State private var menuWidth: CGFloat = 220
        @State private var menuHeight: CGFloat = 240
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject private var cssEditorViewModel: CssEditorViewModel
        
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
                                cssEditorViewModel.customTheme = nil
                                cssEditorViewModel.loadContent(customTheme: nil, modelTheme: htmlViewModel.gzhTheme)
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
        @EnvironmentObject private var cssEditorViewModel: CssEditorViewModel
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
                        cssEditorViewModel.customTheme = theme.customTheme
                        cssEditorViewModel.loadContent(customTheme: htmlViewModel.selectedCustomTheme, modelTheme: nil)
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
    
    struct HelpBubble: View {
        var body: some View {
            VStack(alignment: .leading) {
                Text("欢迎使用自定义主题功能")
                Link("使用教程", destination: URL(string: "https://babyno.top/posts/2024/11/wenyan-supports-customized-themes/")!)
                    .pointingHandCursor()
                Link("功能讨论", destination: URL(string: "https://github.com/caol64/wenyan/discussions/9")!)
                    .pointingHandCursor()
                Link("主题分享", destination: URL(string: "https://github.com/caol64/wenyan/discussions/13")!)
                    .pointingHandCursor()
            }
            .frame(width: 220, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
        }
    }
    
}
