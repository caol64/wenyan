//
//  ContentView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var viewModel: MainViewModel
    
    var body: some View {
        MainUI()
            .frame(minWidth: 1140, idealWidth: .infinity, minHeight: 645, idealHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        viewModel.dispatch(.toggleFileSidebar)
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    ForEach(Platform.allCases) { platform in
                        Button {
                            viewModel.dispatch(.changePlatform(platform))
                        } label: {
                            Image(platform.rawValue)
                        }
                    }
                }
            }
            .navigationTitle(getAppName())
            .background(Color(NSColor.windowBackgroundColor))
            .alert(isPresented: appState.showError, error: appState.appError) {}
            .fileExporter(
                isPresented: $viewModel.isFileExporting,
                document: viewModel.exportFileData,
                contentType: viewModel.exportContentType,
                defaultFilename: viewModel.exportDefaultFilename
            ) { result in
                // 处理保存成功或失败的结果
                switch result {
                case .success(let url):
                    print("文件成功保存到: \(url)")
                case .failure(let error):
                    print("文件保存失败: \(error.localizedDescription)")
                }
            }
    }
}
