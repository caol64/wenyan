//
//  ThemeList.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import SwiftUI

struct ThemeList: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var htmlViewModel: HtmlViewModel

    var body: some View {
        VStack {
            ForEach(Platform.gzh.themes, id: \.self) { theme in
                BuiltinThemeListView(theme: ThemeStyleWrapper(themeType: .builtin, themeStyle: theme))
            }
            ForEach(appState.customThemes, id: \.self) { theme in
                CustomThemeListView(theme: ThemeStyleWrapper(themeType: .custom, customTheme: theme))
            }
            if appState.customThemes.count < 3 {
                HStack {
                    Spacer()
                    Text("创建新主题")
                    Button {
                        appState.dispatch(.openCssEditor(false))
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
    }

    struct BuiltinThemeListView: View {
        @EnvironmentObject private var appState: AppState
        private let theme: ThemeStyleWrapper

        init(theme: ThemeStyleWrapper) {
            self.theme = theme
        }

        var body: some View {
            Button(action: {
                appState.dispatch(.changeTheme(theme))
            }) {
                HStack {
                    Text(theme.name())
                    Spacer()
                    Text(theme.author())
                }
                .foregroundColor(appState.gzhTheme == theme ? Color.white : Color.primary)
                .contentShape(Rectangle())
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            .buttonStyle(.borderless)
            .background(appState.gzhTheme == theme ? Color.accentColor : Color.clear)
        }
    }

    struct CustomThemeListView: View {
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject private var htmlViewModel: HtmlViewModel
        private let theme: ThemeStyleWrapper

        init(theme: ThemeStyleWrapper) {
            self.theme = theme
        }

        var body: some View {
            HStack {
                Button(action: {
                    appState.dispatch(.changeTheme(theme))
                }) {
                    HStack {
                        Text(theme.name())
                        Spacer()
                    }
                }
                .buttonStyle(.borderless)
                .padding(.leading, 5)
                .padding(.vertical, 2)
                .foregroundColor(appState.gzhTheme == theme ? Color.white : Color.primary)

                HStack {
                    Button {
                        appState.dispatch(.changeTheme(theme))
                        appState.dispatch(.openCssEditor(true))
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(appState.gzhTheme == theme ? Color.white : Color.accentColor)
                }
                .padding(.vertical, 2)
                .padding(.trailing, 5)
            }
            .background(appState.gzhTheme == theme ? Color.accentColor : Color.clear)
            .contentShape(Rectangle())
        }
    }
}
