//
//  ParagraphSettingsViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation
import Combine

@MainActor
final class ParagraphSettingsViewModel: ObservableObject {
    private static let key = "paragraphSettings"
    private let htmlViewModel: HtmlViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var paragraphSettings: ParagraphSettings {
        didSet {
            saveSettings()
        }
    }
    
    init(htmlViewModel: HtmlViewModel) {
        self.htmlViewModel = htmlViewModel
        self.paragraphSettings = Self.loadSettings() ?? ParagraphSettings()
        
        $paragraphSettings
            .dropFirst() // 忽略初始化时的值
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] settings in
                self?.applySettings(settings)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(paragraphSettings) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }
    
    private func applySettings(_ settings: ParagraphSettings) {
        htmlViewModel.setParagraphSettings()
        if settings.isEnabled {
            htmlViewModel.applySettings()
        } else {
            htmlViewModel.setTheme()
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
