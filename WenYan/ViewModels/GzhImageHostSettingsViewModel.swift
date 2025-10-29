//
//  GzhImageHostSettingsViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation

class GzhImageHostSettingsViewModel: ObservableObject {
    @Published var gzhImageHost: GzhImageHost {
        didSet {
            saveSettings()
        }
    }
    @Published var isEnabled: Bool = false {
        didSet {
            saveEbabledImageHost()
        }
    }
    private static let key = "gzhImageHost"
    
    init() {
        self.gzhImageHost = Self.loadSettings() ?? GzhImageHost()
        let ebabledImageHost = UserDefaults.standard.string(forKey: "ebabledImageHost")
        if let enabled = ebabledImageHost {
            isEnabled = enabled == Settings.ImageHosts.gzh.id
        }
    }
    
    private func saveSettings() {
        var clone = gzhImageHost
        clone.accessToken = ""
        clone.expireTime = nil
        if let encoded = try? JSONEncoder().encode(clone) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }
    
    private func saveEbabledImageHost() {
        UserDefaults.standard.set(self.isEnabled ? Settings.ImageHosts.gzh.id : "", forKey: "ebabledImageHost")
    }

    private static func loadSettings() -> GzhImageHost? {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(GzhImageHost.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
