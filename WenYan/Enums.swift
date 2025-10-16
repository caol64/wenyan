//
//  Enums.swift
//  WenYan
//
//  Created by Lei Cao on 2024/11/27.
//

enum AppConstants {
    static let defaultAppName = "文颜"
}

enum ThemeStyle: String {
    case gzhDefault
    case toutiaoDefault
    case zhihuDefault
    case juejinDefault
    case mediumDefault
    case orangeheart
    case rainbow
    case lapis
    case pie
    case maize
    case purple
    case phycat
    
    var name: String {
        switch self {
        case .gzhDefault: "默认"
        case .toutiaoDefault: "默认"
        case .zhihuDefault: "默认"
        case .juejinDefault: "默认"
        case .mediumDefault: "默认"
        case .orangeheart: "Orange Heart"
        case .rainbow: "Rainbow"
        case .lapis: "Lapis"
        case .pie: "Pie"
        case .maize: "Maize"
        case .purple: "Purple"
        case .phycat: "物理猫-薄荷"
        }
    }
    
    var author: String {
        switch self {
        case .gzhDefault: ""
        case .toutiaoDefault: ""
        case .zhihuDefault: ""
        case .juejinDefault: ""
        case .mediumDefault: ""
        case .orangeheart: "evgo2017"
        case .rainbow: "thezbm"
        case .lapis: "YiNN"
        case .pie: "kevinzhao2233"
        case .maize: "BEATREE"
        case .purple: "hliu202"
        case .phycat: "sumruler"
        }
    }
}

enum HighlightStyle: String, CaseIterable, Identifiable {
    case atomOneDark = "atom-one-dark"
    case atomOneLight = "atom-one-light"
    case dracula = "dracula"
    case githubDark = "github-dark"
    case github = "github"
    case monokai = "monokai"
    case solarizedDark = "solarized-dark"
    case solarizedLight = "solarized-light"
    case xcode = "xcode"
    
    var id: Self { self }
    
    var path: String {
        switch self {
        case .atomOneDark: "highlight/styles/atom-one-dark.min.css"
        case .atomOneLight: "highlight/styles/atom-one-light.min.css"
        case .dracula: "highlight/styles/dracula.min.css"
        case .githubDark: "highlight/styles/github-dark.min.css"
        case .github: "highlight/styles/github.min.css"
        case .monokai: "highlight/styles/monokai.min.css"
        case .solarizedDark: "highlight/styles/solarized-dark.min.css"
        case .solarizedLight: "highlight/styles/solarized-light.min.css"
        case .xcode: "highlight/styles/xcode.min.css"
        }
    }
}

enum PreviewMode: String {
    case mobile = "style.css"
    case desktop = "desktop_style.css"
}

enum Platform: String, CaseIterable, Identifiable {
    case gzh
    case toutiao
    case zhihu
    case juejin
    case medium
    
    var id: Self { self }
    
    var themes: [ThemeStyle] {
        switch self {
        case .gzh: [.gzhDefault, .orangeheart, .rainbow, .lapis, .pie, .maize, .purple, .phycat]
        case .zhihu: [.zhihuDefault]
        case .toutiao: [.toutiaoDefault]
        case .juejin: [.juejinDefault]
        case .medium: [.mediumDefault]
        }
    }
}

enum ThemeType {
    case builtin
    case custom
}

enum EditorMode {
    case normal
    case developer
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
