//
//  ToolButtonPopup.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/28.
//

import SwiftUI

struct ToolButtonPopup: View {
    @EnvironmentObject private var htmlViewModel: HtmlViewModel
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            // MARK: - 主题按钮
            if appState.platform == .gzh {
                Button(action: {
                    withAnimation { appState.showInspector.toggle() }
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
            
            // MARK: - 切换脚注按钮
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

            // MARK: - 导出长图按钮
            Button(action: {
                htmlViewModel.exportContent(as: .longImage)
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
                isPresented: htmlViewModel.isImgExporting,
                document: htmlViewModel.exportImgData,
                contentType: .jpeg,
                defaultFilename: "out"
            ) { result in
                htmlViewModel.handleExportResult(result)
            }
            
            // MARK: - 导出PDF按钮
            Button(action: {
                htmlViewModel.exportContent(as: .pdf)
            }) {
                HStack {
                    Image(systemName: "text.document")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                    Text("PDF")
                        .font(.system(size: 14))
                }
                .frame(height: 24)
            }
            .fileExporter(
                isPresented: htmlViewModel.isPdfExporting,
                document: htmlViewModel.exportPdfData,
                contentType: .pdf,
                defaultFilename: "out"
            ) { result in
                htmlViewModel.handleExportResult(result)
            }
            
            // MARK: - 复制按钮
            CopyButton()
        }
        .padding(.trailing, 32)
        .padding(.top, 16)
    }
}
