//
//  GzhImageHostSettingsView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import SwiftUI

// 公众号图床设置视图
struct GzhImageHostSettingsView: View {
    @StateObject private var viewModel = GzhImageHostSettingsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text(Settings.ImageHosts.gzh.rawValue)
                .font(.title2)
                .bold()
            
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("启用")
                            .bold()
                        Spacer()
                        Toggle("", isOn: $viewModel.isEnabled.animation(.easeInOut(duration: 0.25)))
                            .toggleStyle(.switch)
                    }
                    .padding(.bottom, 8)
                    
                    if viewModel.isEnabled {
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

        }
        .padding()
    }
}
