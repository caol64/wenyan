//
//  CodeblockSettingsView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import SwiftUI

// 代码块设置视图
struct CodeblockSettingsView: View {
    @EnvironmentObject private var viewModel: CodeblockSettingsViewModel
    @State private var showBubble = false

    var body: some View {

        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("跟随主题")
                    Spacer()
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { !viewModel.codeblockSettings.isEnabled },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.codeblockSettings.isEnabled = !newValue
                                }
                            }
                        )
                    )
                    .toggleStyle(.switch)
                }
                .padding(.bottom, 4)

                if viewModel.codeblockSettings.isEnabled {
                    HStack {
                        Text("Mac 风格")
                        Spacer()
                        Toggle("", isOn: $viewModel.codeblockSettings.isMacStyle)
                            .toggleStyle(.checkbox)
                    }
                    .padding(.bottom, 4)

                    Text("高亮主题")
                    Picker("", selection: $viewModel.codeblockSettings.theme) {
                        ForEach(HlThemeConfig.themes(), id: \.self) { style in
                            Text(style).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.bottom, 4)

                    Text("字体大小")
                    Picker("", selection: $viewModel.codeblockSettings.fontSize) {
                        ForEach(FontSize.allCases, id: \.self.rawValue) { fontSize in
                            Text(fontSize.rawValue).tag(fontSize.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.bottom, 4)

                    HStack {
                        Text("字体")
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
            }
            if showBubble {
                Text("你可以在这里设置你本机上已经安装的字体，但请注意：这里设置的字体只会影响你本地预览、导出图片时的显示，并不会影响公众号发布后用户看到的字体。具体说明请参阅“使用帮助”。")
                    .padding()
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .frame(width: 240)
            }
        }
    }

}
