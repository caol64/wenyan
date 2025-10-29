//
//  Themes.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import Foundation

struct ThemeStyleWrapper: Equatable, Hashable {
    let themeType: ThemeType
    let themeStyle: ThemeStyle?
    let customTheme: CustomTheme?
    
    init(themeType: ThemeType, themeStyle: ThemeStyle? = nil, customTheme: CustomTheme? = nil) {
        self.themeType = themeType
        self.themeStyle = themeStyle
        self.customTheme = customTheme
    }
    
    static func getDefault() -> ThemeStyleWrapper {
        ThemeStyleWrapper(themeType: .builtin, themeStyle: ThemeStyle(id: "default"))
    }
    
    static func == (lhs: ThemeStyleWrapper, rhs: ThemeStyleWrapper) -> Bool {
        if lhs.themeType == .builtin {
            return rhs.themeType == .builtin && lhs.themeStyle!.id == rhs.themeStyle!.id
        }
        if lhs.themeType == .custom {
            return rhs.themeType == .custom && lhs.customTheme == rhs.customTheme
        }
        return false
    }
    
    func name() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.name
        case .custom:
            return customTheme!.name ?? ""
        }
    }
    
    func author() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.author
        case .custom:
            return ""
        }
    }
    
    func id() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.id
        case .custom:
            return "custom/\(customTheme!.objectID.uriRepresentation().absoluteString)"
        }
    }
}

struct ThemeStyle: Hashable {
    let id: String
    let name: String
    let author: String
    
    init(id: String, name: String = "默认", author: String = "") {
        self.id = id
        self.name = name
        self.author = author
    }
}

struct PlatformConfig {
    // Lazy Initialization
    private static var _themes: [Platform: [ThemeStyle]] = [:]
    
    static func setThemes(body: [[String: String]]) {
        let themes = body.compactMap { dict -> ThemeStyle? in
            guard let id = dict["id"], let name = dict["appName"] else { return nil }
            return ThemeStyle(id: id, name: name, author: dict["author"] ?? "")
        }
        _themes[.gzh] = themes
        _themes[.toutiao] = [ThemeStyle(id: "toutiao_default")]
        _themes[.zhihu] = [ThemeStyle(id: "zhihu_default")]
        _themes[.juejin] = [ThemeStyle(id: "juejin_default")]
        _themes[.medium] = [ThemeStyle(id: "medium_default")]
    }
    
    static func themes(for platform: Platform) -> [ThemeStyle] {
        _themes[platform] ?? []
    }
}

struct HlThemeConfig {
    // Lazy Initialization
    private static var _themes: [String] = []
    
    static func setThemes(body: [[String: String]]) {
        let themes = body.compactMap { dict -> String? in
            guard let id = dict["id"] else { return nil }
            return id
        }
        _themes = themes
    }
    
    static func themes() -> [String] {
        _themes
    }
}
