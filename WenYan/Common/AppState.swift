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
    @Published var showDeleteButton = false
    @Published var isCopied = false
    @Published var platform: Platform = .gzh
    @Published var showInspector = false
    @Published var showSheet = false
    @Published var gzhTheme = ThemeStyleWrapper.getDefault()
    @Published var customThemes: [CustomTheme] = []
    
    func initial() {
        fetchCustomThemes()
        if platform == .gzh {
            if let themeId = UserDefaults.standard.string(forKey: "gzhTheme") {
                if themeId.starts(with: "custom/") {
                    if let customTheme = getCustomThemeById(id: themeId.replacingOccurrences(of: "custom/", with: "")) {
                        changeTheme(ThemeStyleWrapper(themeType: .custom, customTheme: customTheme))
                    }
                } else {
                    let themeStyle = Platform.gzh.theme(withId: themeId)
                    changeTheme(ThemeStyleWrapper(themeType: .builtin, themeStyle: themeStyle))
                }
            }
        }
    }
    
    func dispatch(_ action: UserAction) {
        switch action {
        case .changePlatform(let platform):
            self.platform = platform
            showInspector = false
        case .changeTheme(let theme):
            changeTheme(theme)
        case .openCssEditor(let showDeleteButton):
            self.showDeleteButton = showDeleteButton
            showSheet = true
        case .deleteCustomTheme:
            self.deleteCustomTheme()
        case .saveCustomTheme(let content):
            saveCustomTheme(content: content)
            fetchCustomThemes()
        }
    }
    
    func changeTheme(_ theme: ThemeStyleWrapper) {
        self.gzhTheme = theme
        UserDefaults.standard.set(gzhTheme.id(), forKey: "gzhTheme")
    }
    
    func toggleCopyIcon() {
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.isCopied = false
            }
        }
    }
    
    // MARK: - CoreData Interaction
    func fetchCustomThemes() {
        do {
            customThemes = try WenYan.fetchCustomThemes()
        } catch {
            error.handle(in: self)
        }
    }

    func deleteCustomTheme() {
        if let customTheme = gzhTheme.customTheme {
            do {
                try WenYan.deleteCustomTheme(customTheme)
            } catch {
                error.handle(in: self)
            }
            fetchCustomThemes()
        }
        changeTheme(ThemeStyleWrapper.getDefault())
    }

    func getCustomThemeById(id: String) -> CustomTheme? {
        return customThemes.filter { item in
            item.objectID.uriRepresentation().absoluteString == id
        }.first
    }
    
    func getCurrentCustomTheme() -> CustomTheme? {
        return getCustomThemeById(id: gzhTheme.id().replacingOccurrences(of: "custom/", with: ""))
    }

    func saveCustomTheme(content: String) {
        do {
            if let customTheme = gzhTheme.customTheme {
                try WenYan.updateCustomTheme(customTheme: customTheme, content: content)
                changeTheme(ThemeStyleWrapper(themeType: .custom, customTheme: customTheme))
            } else {
                let customTheme = try WenYan.saveCustomTheme(content: content)
                changeTheme(ThemeStyleWrapper(themeType: .custom, customTheme: customTheme))
            }
        } catch {
            error.handle(in: self)
        }
    }
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
