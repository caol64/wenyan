//
//  AppState.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var appError: AppError?
}

extension AppState {
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
