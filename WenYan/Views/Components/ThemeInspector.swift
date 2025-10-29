//
//  ThemeInspector.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import SwiftUI

struct ThemeInspector: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var htmlViewModel: HtmlViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("选择主题").font(.headline)
                    Spacer()
                    
                    Button {
                        appState.showInspector = false
                    } label: {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                }
                Divider()
                ThemeList()
                Text("段落设置").font(.headline).padding(.top, 8)
                Divider()
                ParagraphSettingsView()
                Text("代码块设置").font(.headline).padding(.top, 8)
                Divider()
                CodeblockSettingsView()
                Spacer()
            }
            .padding()
        }
    }
}
