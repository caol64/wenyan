//
//  CodeblockSettingsViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation
import Combine

@MainActor
class CodeblockSettingsViewModel: ObservableObject {
    private static let key = "codeblockSettings"
    private let htmlViewModel: HtmlViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var codeblockSettings: CodeblockSettings {
        didSet {
            saveSettings()
        }
    }
    
    init(htmlViewModel: HtmlViewModel) {
        self.htmlViewModel = htmlViewModel
        self.codeblockSettings = Self.loadSettings() ?? CodeblockSettings()
        
        $codeblockSettings
            .dropFirst() // 忽略初始化时的值
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] settings in
                self?.applySettings(settings)
            }
            .store(in: &cancellables)
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(codeblockSettings) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }
    
    private func applySettings(_ settings: CodeblockSettings) {
        htmlViewModel.setCodeblockSettings()
        htmlViewModel.applySettings()
    }

    static func loadSettings() -> CodeblockSettings? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(CodeblockSettings.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
