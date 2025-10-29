//
//  ParagraphSettingsViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation

@MainActor
class ParagraphSettingsViewModel: ObservableObject {
    private let htmlViewModel: HtmlViewModel
    @Published var paragraphSettings: ParagraphSettings {
        didSet {
            saveSettings()
            htmlViewModel.setParagraph(paragraphSettings: paragraphSettings)
        }
    }
    private static let key = "paragraphSettings"
    
    init(htmlViewModel: HtmlViewModel) {
        self.htmlViewModel = htmlViewModel
        self.paragraphSettings = Self.loadSettings() ?? ParagraphSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(paragraphSettings) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    static func loadSettings() -> ParagraphSettings? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(ParagraphSettings.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
