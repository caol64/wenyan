//
//  ContentView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        MainUI()
            .frame(minWidth: 1140, idealWidth: .infinity, minHeight: 645, idealHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        mainViewModel.dispatch(.toggleFileSidebar)
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    ForEach(Platform.allCases) { platform in
                        Button {
                            mainViewModel.dispatch(.changePlatform(platform))
                        } label: {
                            Image(platform.rawValue)
                        }
                    }
                }
            }
            .navigationTitle(getAppName())
            .background(Color(NSColor.windowBackgroundColor))
            .alert(isPresented: appState.showError, error: appState.appError) {}
    }
}
