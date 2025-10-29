//
//  ParagraphSettingsView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import SwiftUI

// 段落设置视图
struct ParagraphSettingsView: View {
    @EnvironmentObject private var viewModel: ParagraphSettingsViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("跟随主题")
                    Spacer()
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { !viewModel.paragraphSettings.isEnabled },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.paragraphSettings.isEnabled = !newValue
                                }
                            }
                        )
                    )
                    .toggleStyle(.switch)
                }
                .padding(.bottom, 4)

                if viewModel.paragraphSettings.isEnabled {
                    Text("字体大小")
                    Picker("", selection: $viewModel.paragraphSettings.fontSize) {
                        ForEach(FontSize.allCases, id: \.self.rawValue) { fontSize in
                            Text(fontSize.rawValue).tag(fontSize.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.bottom, 4)

                    Text("字体")
                    Picker("", selection: $viewModel.paragraphSettings.fontType) {
                        ForEach(FontType.allCases, id: \.self.rawValue) { style in
                            Text(style.label).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)

                    Text("文字粗细")
                    Picker("", selection: $viewModel.paragraphSettings.fontWeight) {
                        ForEach(FontWeight.allCases, id: \.self.rawValue) { style in
                            Text(style.label).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)

                    Text("字间距")
                    Picker("", selection: $viewModel.paragraphSettings.wordSpacing) {
                        ForEach(WordSpacing.allCases, id: \.self.rawValue) { style in
                            Text(style.label).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)

                    Text("行间距")
                    Picker("", selection: $viewModel.paragraphSettings.lineSpacing) {
                        ForEach(LineSpacing.allCases, id: \.self.rawValue) { style in
                            Text(style.label).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)

                    Text("段落间距")
                    Picker("", selection: $viewModel.paragraphSettings.paragraphSpacing) {
                        ForEach(ParagraphSpacing.allCases, id: \.self.rawValue) { style in
                            Text(style.label).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)
                }
            }
        }
    }

}
