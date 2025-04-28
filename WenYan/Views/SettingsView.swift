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
            .frame(width: 650, height: 400)
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
            SidebarItem(title: "代码块设置", id: Settings.codeblock, padding: 8)
        }
        .padding(.leading, 8)
        .listStyle(.sidebar)
        .frame(minWidth: 200, maxWidth: 200, minHeight: 400, maxHeight: 400)
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
                CodeblockSettingsView()
            default:
                CardView {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("文颜设置")
                    }
                }
            }
        }
        .frame(minWidth: 450, maxWidth: 450, minHeight: 400, maxHeight: 400, alignment: .topLeading)
        .padding()
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
    }
}

// 公众号图床设置视图
struct GzhImageHostSettingsView: View {
    @StateObject private var viewModel = GzhImageHostSettingsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Settings.ImageHosts.gzh.rawValue)
                    .font(.title2)
                    .bold()
                Spacer()
                Toggle("", isOn: $viewModel.isEnabled)
                    .toggleStyle(.switch)
            }
            
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("开发者ID(AppID)")
                        .bold()
                    TextField("如：wx6e1234567890efa3", text: $viewModel.gzhImageHost.appId)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 8)
                    
                    Text("开发者密码(AppSecret)")
                        .bold()
                    TextField("如：d9f1abcdef01234567890abcdef82397", text: $viewModel.gzhImageHost.appSecret)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Spacer()
                        Text("请务必开启“IP白名单”")
                    }
                    .padding(.top, 16)
                    HStack {
                        Spacer()
                        Link("使用帮助", destination: URL(string: "https://yuzhi.tech/docs/wenyan/upload")!)
                            .pointingHandCursor()
                    }
                }
            }

        }
        .padding()
    }
}

class GzhImageHostSettingsViewModel: ObservableObject {
    @Published var gzhImageHost: GzhImageHost {
        didSet {
            saveSettings()
        }
    }
    @Published var isEnabled: Bool = false {
        didSet {
            saveEbabledImageHost()
        }
    }
    private static let key = "gzhImageHost"
    
    init() {
        self.gzhImageHost = Self.loadSettings() ?? GzhImageHost()
        let ebabledImageHost = UserDefaults.standard.string(forKey: "ebabledImageHost")
        if let enabled = ebabledImageHost {
            isEnabled = enabled == Settings.ImageHosts.gzh.id
        }
    }
    
    private func saveSettings() {
        var clone = gzhImageHost
        clone.accessToken = ""
        clone.expireTime = nil
        if let encoded = try? JSONEncoder().encode(clone) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }
    
    private func saveEbabledImageHost() {
        UserDefaults.standard.set(self.isEnabled ? Settings.ImageHosts.gzh.id : "", forKey: "ebabledImageHost")
    }

    private static func loadSettings() -> GzhImageHost? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(GzhImageHost.self, from: savedData) {
            return decoded
        }
        return nil
    }
}

// 代码块设置视图
struct CodeblockSettingsView: View {
    @StateObject private var viewModel = CodeblockSettingsViewModel()
    @EnvironmentObject private var htmlViewModel: HtmlViewModel
    @State private var showBubble = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("代码块设置")
                    .font(.title2)
                    .bold()
            }
            
            CardView {
                ZStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Mac 风格")
                                .bold()
                            Spacer()
                            Toggle("", isOn: $viewModel.codeblockSettings.isMacStyle)
                                .toggleStyle(.switch)
                        }
                        .padding(.bottom, 8)
                        
                        Text("高亮主题")
                            .bold()
                        Picker("", selection: $viewModel.codeblockSettings.theme) {
                            ForEach(HighlightStyle.allCases, id: \.self.rawValue) { style in
                                Text(style.rawValue).tag(style.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.bottom, 8)
                        
                        Text("字体大小")
                            .bold()
                        Picker("", selection: $viewModel.codeblockSettings.fontSize) {
                            ForEach(FontSize.allCases, id: \.self.rawValue) { fontSize in
                                Text(fontSize.rawValue).tag(fontSize.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        
                        HStack {
                            Text("字体")
                                .bold()
                                Button("", systemImage: "questionmark.circle") {
                                    showBubble = true
                                }
                                .buttonStyle(.borderless)
                                .font(.system(size: 13))
                                .onHover { hovering in
                                    if hovering {
                                        showBubble = true
                                    } else {
                                        showBubble = false
                                    }
                                }
                        }
                        TextField("如：JetBrains Mono", text: $viewModel.codeblockSettings.fontFamily)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Spacer()
                            Link("使用帮助", destination: URL(string: "https://yuzhi.tech/docs/wenyan/codeblock")!)
                                .pointingHandCursor()
                        }
                        .padding(.top, 16)
                    }
                    if showBubble {
                        Text("你可以在这里设置你本机上已经安装的字体，但请注意：这里设置的字体只会影响你本地预览、导出图片时的显示，并不会影响公众号发布后用户看到的字体。具体说明请参阅“使用帮助”。")
                            .padding()
                            .offset(x: 20, y: 40)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white)
                                    .shadow(radius: 5)
                                    .offset(x: 20, y: 40)
                            )
                            .frame(width: 300, height: 120)
                    }
                }
                .onReceive(viewModel.$codeblockSettings) { newContent in
                    if let highlightStyle = HighlightStyle(rawValue: newContent.theme) {
                        htmlViewModel.highlightStyle = highlightStyle
                    }
                    htmlViewModel.codeblockSettings.fontSize = newContent.fontSize
                    htmlViewModel.codeblockSettings.fontFamily = newContent.fontFamily
                    htmlViewModel.setCodeblock()
                    htmlViewModel.setTheme()
                    newContent.isMacStyle ? htmlViewModel.setMacStyle() : htmlViewModel.removeMacStyle()
                }
            }

        }
        .padding()
    }
}

class CodeblockSettingsViewModel: ObservableObject {
    @Published var codeblockSettings: CodeblockSettings {
        didSet {
            saveSettings()
        }
    }
    private static let key = "codeblockSettings"
    
    init() {
        self.codeblockSettings = Self.loadSettings() ?? CodeblockSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(codeblockSettings) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    static func loadSettings() -> CodeblockSettings? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(CodeblockSettings.self, from: savedData) {
            return decoded
        }
        return nil
    }
}

struct CodeblockSettings: Codable {
    var isMacStyle: Bool = false
    var theme: String = HighlightStyle.github.rawValue
    var fontSize: String = FontSize.px12.rawValue
    var fontFamily: String = ""
}
