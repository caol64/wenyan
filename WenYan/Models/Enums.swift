//
//  Enums.swift
//  WenYan
//
//  Created by Lei Cao on 2024/11/27.
//

// MARK: - User Intents
enum UserAction {
    case changePlatform(Platform)
    case changeTheme(ThemeStyleWrapper)
    case openCssEditor(Bool)
    case deleteCustomTheme
    case saveCustomTheme(String)
}

enum AppConstants {
    static let defaultAppName = "文颜"
}

enum WebkitStatus {
    static let loadHandler = "loadHandler"
    static let contentChangeHandler = "contentChangeHandler"
    static let scrollHandler = "scrollHandler"
    static let errorHandler = "errorHandler"
    static let uploadHandler = "uploadHandler"
    static let loadThemesHandler = "loadThemesHandler"
}

enum Platform: String, CaseIterable, Identifiable {
    case gzh
    case toutiao
    case zhihu
    case juejin
    case medium
    
    var id: Self { self }
    
    var themes: [ThemeStyle] {
        PlatformConfig.themes(for: self)
    }
    
    func theme(withId id: String) -> ThemeStyle {
        if self == .gzh {
            themes.first { $0.id == id } ?? themes[0]
        } else {
            themes[0]
        }
    }
}

enum ThemeType {
    case builtin
    case custom
}

enum ExportType {
    case pdf
    case longImage
}

enum Settings: Identifiable, Hashable {
    enum ImageHosts: String, CaseIterable, Identifiable {
        case gzh = "公众号图床"
        
        var id: String {
            switch self {
            case .gzh: "gzh"
            }
        }
    }
    
    case imageHosts(ImageHosts)
    case codeblock
    case paragraph
    
    var id: String {
        switch self {
        case .imageHosts(let imageHost): imageHost.id
        case .codeblock: "codeblock"
        case .paragraph: "paragraph"
        }
    }
}

enum FontSize: String, CaseIterable, Identifiable {
    case px12 = "12px"
    case px13 = "13px"
    case px14 = "14px"
    case px15 = "15px"
    case px16 = "16px"
    case px17 = "17px"
    case px18 = "18px"
    
    var id: Self { self }
}

enum FontType: String, CaseIterable, Identifiable {
    case serif = "serif"
    case sans = "sans"
    case mono = "mono"
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .serif:
            "衬线"
        case .sans:
            "无衬线"
        case .mono:
            "等宽"
        }
    }
}

enum FontWeight: String, CaseIterable, Identifiable {
    case _300 = "300"
    case _400 = "400"
    case _500 = "500"
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case ._300:
            "较细"
        case ._400:
            "标准"
        case ._500:
            "较粗"
        }
    }
}

enum WordSpacing: String, CaseIterable, Identifiable {
    case small = "0.05em"
    case medium = "0.1em"
    case mediumLarge = "0.15em"
    case large = "0.2em"
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .small:
            "小"
        case .medium:
            "标准"
        case .mediumLarge:
            "较大"
        case .large:
            "大"
        }
    }
}

enum LineSpacing: String, CaseIterable, Identifiable {
    case small = "1.5"
    case medium = "1.75"
    case mediumLarge = "2"
    case large = "2.25"
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .small:
            "小"
        case .medium:
            "标准"
        case .mediumLarge:
            "较大"
        case .large:
            "大"
        }
    }
}

enum ParagraphSpacing: String, CaseIterable, Identifiable {
    case small = "0.75em"
    case medium = "1em"
    case mediumLarge = "1.5em"
    case large = "2em"
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .small:
            "小"
        case .medium:
            "标准"
        case .mediumLarge:
            "较大"
        case .large:
            "大"
        }
    }
}
