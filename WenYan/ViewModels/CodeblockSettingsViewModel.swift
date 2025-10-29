//
//  CodeblockSettingsViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation

@MainActor
class CodeblockSettingsViewModel: ObservableObject {
    private let htmlViewModel: HtmlViewModel
    @Published var codeblockSettings: CodeblockSettings {
        didSet {
            saveSettings()
            htmlViewModel.setCodeblock(codeblockSettings: codeblockSettings)
        }
    }
    private static let key = "codeblockSettings"
    
    init(htmlViewModel: HtmlViewModel) {
        self.htmlViewModel = htmlViewModel
        self.codeblockSettings = Self.loadSettings() ?? CodeblockSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(codeblockSettings) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    static func loadSettings() -> CodeblockSettings? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(CodeblockSettings.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
