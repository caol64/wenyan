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
            Button(action: {
                htmlViewModel.onCopy()
            }) {
                HStack {
                    Image(systemName: appState.isCopied ? "checkmark" : "clipboard")
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
    }
}
