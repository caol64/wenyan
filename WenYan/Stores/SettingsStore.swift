//
//  SettingsStore.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/24.
//

import Foundation

// MARK: - ParagraphSettings
struct ParagraphSettings: Codable {
    var isFollowTheme: Bool = true
    var lineHeight: String = "1.75"
    var fontSize: String = "16px"
    var fontWeight: String = "400"
    var fontFamily: String = "sans"
    var paragraphSpacing: String = "1em"
    var letterSpacing: String = "0.1em"
}

// MARK: - CodeblockSettings
struct CodeblockSettings: Codable {
    var isFollowTheme: Bool = true
    var isMacStyle: Bool = true
    var fontSize: String = "12px"
    var fontFamily: String?
    var hlThemeId: String = "github"
}

// MARK: - UploadSettings
struct UploadSettings: Codable {
    var autoUploadLocal: Bool = false
    var autoUploadNetwork: Bool = false
    var autoCache: Bool = false
}

// MARK: - Settings
struct Settings: Codable {
    var wechatTheme: String = "default"
    var enabledImageHost: String?
    var paragraphSettings: ParagraphSettings = ParagraphSettings()
    var codeblockSettings: CodeblockSettings = CodeblockSettings()
    var uploadSettings: UploadSettings = UploadSettings()
}

func getSettings() -> Settings? {
    if let savedData = UserDefaults.standard.data(forKey: "wenyanSettings"),
       let decoded = try? JSONDecoder().decode(Settings.self, from: savedData) {
        return decoded
    }
    // 兼容老数据
    var settings = Settings()
    if let hostID = UserDefaults.standard.string(forKey: "ebabledImageHost"), !hostID.isEmpty {
        settings.enabledImageHost = "wechat"
    }
    UserDefaults.standard.removeObject(forKey: "ebabledImageHost")
    if let savedData = UserDefaults.standard.data(forKey: "paragraphSettings"),
       let decoded = try? JSONDecoder().decode(_ParagraphSettings.self, from: savedData) {
        settings.paragraphSettings = decoded.convertTo()
    }
    UserDefaults.standard.removeObject(forKey: "paragraphSettings")
    if let savedData = UserDefaults.standard.data(forKey: "codeblockSettings"),
       let decoded = try? JSONDecoder().decode(_CodeblockSettings.self, from: savedData) {
        settings.codeblockSettings = decoded.convertTo()
    }
    UserDefaults.standard.removeObject(forKey: "codeblockSettings")
    if let gzhTheme = UserDefaults.standard.string(forKey: "gzhTheme") {
        settings.wechatTheme = gzhTheme.replacingOccurrences(of: "custom/", with: "custom:")
    }
    UserDefaults.standard.removeObject(forKey: "gzhTheme")
    saveSettings(settings: settings)
    return settings
}

func saveSettings(settings: Settings) {
    if let encoded = try? JSONEncoder().encode(settings) {
        UserDefaults.standard.set(encoded, forKey: "wenyanSettings")
    }
}

func clearSettings() {
    UserDefaults.standard.removeObject(forKey: "wenyanSettings")
}

// MARK: 老数据
private struct _CodeblockSettings: Codable {
    var isEnabled = false
    var isMacStyle = false
    var theme = "github"
    var fontSize = "12px"
    var fontFamily = ""
}

private struct _ParagraphSettings: Codable {
    var isEnabled = false
    var fontSize = "16px"
    var fontType = "sans"
    var fontWeight = "400"
    var wordSpacing = "0.1em"
    var lineSpacing = "1.75"
    var paragraphSpacing = "1em"
}

extension _CodeblockSettings {
    func convertTo() -> CodeblockSettings {
        return CodeblockSettings(
            isFollowTheme: !self.isEnabled,
            isMacStyle: self.isMacStyle,
            fontSize: self.fontSize,
            fontFamily: self.fontFamily,
            hlThemeId: self.theme
        )
    }
}

extension _ParagraphSettings {
    func convertTo() -> ParagraphSettings {
        return ParagraphSettings(
            isFollowTheme: !self.isEnabled,
            lineHeight: self.lineSpacing,
            fontSize: self.fontSize,
            fontWeight: self.fontWeight,
            fontFamily: self.fontType,
            paragraphSpacing: self.paragraphSpacing,
            letterSpacing: self.wordSpacing
        )
    }
}
