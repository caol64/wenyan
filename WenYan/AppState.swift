//
//  AppState.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var appError: AppError?
    @Published var showThemeList = false
    @Published var showConfirm = false
    @Published var showSheet = false
    @Published var showHelpBubble = false
    @Published var showDeleteButton = false

    var showError: Binding<Bool> {
        Binding {
            return self.appError != nil
        } set: { showError in
            if !showError {
                self.appError = nil
            }
        }
    }
}


enum AppError: LocalizedError {
    case bizError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .bizError(let description):
            return description
        }
    }
}
