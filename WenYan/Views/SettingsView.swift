//
//  SettingsView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/2/18.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: String? = ImageHosts.gzh.id // 选中的侧边栏
    @State private var appId: String = ""
    @State private var appSecret: String = ""
    @State private var isEnabled: Bool = false

    var body: some View {
        NavigationView {
            // 侧边栏
            List(selection: $selectedTab) {
                Section(header: Text("图床设置")) {
                    ForEach(ImageHosts.allCases) { imageHost in
                        SidebarItem(title: imageHost.rawValue, id: imageHost.id)
                    }
                }
            }
            .listStyle(.sidebar)

            // 右侧详情视图
            VStack(alignment: .leading) {
                if selectedTab == ImageHosts.gzh.id {
                    GzhImageHostSettingsView()
                } else {
                    CardView {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("文颜设置")
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 700, height: 400)
    }
}

// 侧边栏 item
struct SidebarItem: View {
    let title: String
    let id: String
    
    var body: some View {
        Text(title)
            .tag(id)
            .padding(.leading, 8)
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
    @StateObject private var viewModel = GzhImageHostSettingsManager()
    @State private var isEnabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(ImageHosts.gzh.rawValue)
                    .font(.title2)
                    .bold()
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: isEnabled) { newValue in
                        UserDefaults.standard.set(self.isEnabled ? ImageHosts.gzh.id : "", forKey: "ebabledImageHost")
                    }
            }
            
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("开发者ID(AppID)")
                        .bold()
                    TextField("如：wx6e1234567890efa3", text: $viewModel.gzhImageHost.appId)
                        .textFieldStyle(.roundedBorder)
                    Text("开发者密码(AppSecret)")
                        .bold()
                    TextField("如：d9f1abcdef01234567890abcdef82397", text: $viewModel.gzhImageHost.appSecret)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
            }

        }
        .padding()
        .task {
            let ebabledImageHost = UserDefaults.standard.string(forKey: "ebabledImageHost")
            if let enabled = ebabledImageHost {
                isEnabled = enabled == ImageHosts.gzh.id
            }
        }
    }
}

class GzhImageHostSettingsManager: ObservableObject {
    @Published var gzhImageHost: GzhImageHost {
        didSet {
            saveSettings()
        }
    }
    private static let key = "gzhImageHost"
    
    init() {
        self.gzhImageHost = Self.loadSettings() ?? GzhImageHost()
    }
    
    private func saveSettings() {
        var clone = gzhImageHost
        clone.accessToken = ""
        clone.expireTime = nil
        if let encoded = try? JSONEncoder().encode(clone) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    private static func loadSettings() -> GzhImageHost? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(GzhImageHost.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
