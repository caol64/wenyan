//
//  SettingsView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/2/18.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: Settings? = .imageHosts(.gzh)

    var body: some View {
        Group {
            NavigationView {
                // 侧边栏
                Sidebar(selectedTab: $selectedTab)
                // 右侧详情视图
                SettingsContent(selectedTab: $selectedTab)
            }
            .frame(width: 650, height: 550)
        }
    }
}

// 侧边栏
struct Sidebar: View {
    @Binding var selectedTab: Settings?

    var body: some View {
        List(selection: $selectedTab) {
            Section {
                ForEach(Settings.ImageHosts.allCases) { imageHost in
                    SidebarItem(title: imageHost.rawValue, id: Settings.imageHosts(imageHost), padding: 16)
                }
            } header: {
                HStack {
                    Image(systemName: "square.grid.2x2")
                    Text("图床设置").font(.headline)
                }
                .padding(.leading, 8)
            }
            SidebarItem(title: "段落设置", id: Settings.paragraph, padding: 8)
            SidebarItem(title: "代码块设置", id: Settings.codeblock, padding: 8)
        }
        .padding(.leading, 8)
        .listStyle(.sidebar)
        .frame(minWidth: 200, maxWidth: 200, minHeight: 550, maxHeight: 550)
    }
}

// 侧边栏 item
struct SidebarItem: View {
    let title: String
    let id: Settings
    let padding: CGFloat

    var body: some View {
        Text(title)
            .tag(id)
            .padding(.leading, padding)
    }
}

struct SettingsContent: View {
    @Binding var selectedTab: Settings?

    var body: some View {
        VStack(alignment: .leading) {
            switch selectedTab {
            case .imageHosts(let imageHost):
                if imageHost == .gzh {
                    GzhImageHostSettingsView()
                }
            case .codeblock:
                VStack(alignment: .leading) {
                    HStack {
                        Text("代码块设置")
                            .font(.title2)
                            .bold()
                    }

                    CardView {
                        CodeblockSettingsView()
                    }
                }
                .padding()
            case .paragraph:
                VStack(alignment: .leading) {
                    HStack {
                        Text("段落设置")
                            .font(.title2)
                            .bold()
                    }

                    CardView {
                        ParagraphSettingsView()
                    }
                }
                .padding()
            default:
                CardView {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("文颜设置")
                    }
                }
            }
        }
        .frame(minWidth: 450, maxWidth: 450, minHeight: 550, maxHeight: 550, alignment: .topLeading)
        .padding()
    }
}
