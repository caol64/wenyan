//
//  WenYanApp.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI
import SwiftData

@main
struct WenYanApp: App {
    
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .alert(isPresented: appState.showError, error: appState.appError) {}
        }
    }
}
