//
//  AppState.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import SwiftUI

@Observable
class AppState {
    var appError: AppError?
    var showError: Binding<Bool> {
        Binding {
            return self.appError != nil
        } set: { showError in
            if !showError {
                self.appError = nil
            }
        }
    }
    var showThemeList: Bool = false
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
