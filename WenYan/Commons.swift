//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit

struct WebkitStatus {
    static let loadHandler = "loadHandler"
    static let contentChangeHandler = "contentChangeHandler"
    static let scrollHandler = "scrollHandler"
    static let clickHandler = "clickHandler"
}

// Helper to convert Swift string to JavaScript string literal
extension String {
    func toJavaScriptString() -> String {
        let escapedString = self
            .replacingOccurrences(of: "\\", with: "\\\\")  // 转义反斜杠
            .replacingOccurrences(of: "\"", with: "\\\"")  // 转义引号
            .replacingOccurrences(of: "\n", with: "\\n")   // 转义换行符
            .replacingOccurrences(of: "\r", with: "\\r")   // 转义回车符
            .replacingOccurrences(of: "\t", with: "\\t")   // 转义制表符
        
        // 添加前后引号，形成合法的 JavaScript 字符串字面量
        return "\"\(escapedString)\""
    }
}

func getResourceBundle() -> URL? {
    return Bundle.main.url(forResource: "Resources", withExtension: "bundle")
}

func loadFile(_ path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: .utf8)
}

func loadFileFromResource(path: String) throws -> String {
    let nsPath = path as NSString
    let path = nsPath.deletingPathExtension
    let `extension` = nsPath.pathExtension
    return try loadFileFromResource(forResource: path, withExtension: `extension`)
}

func loadFileFromResource(forResource: String, withExtension: String) throws -> String {
    guard
        let resourceBundleURL = getResourceBundle(),
        let resourceBundle = Bundle(url: resourceBundleURL),
        let filePath = resourceBundle.path(forResource: forResource, ofType: withExtension)
    else {
        throw AppError.bizError(description: "Required resource is missing")
    }
    return try loadFile(filePath)
}

typealias JavascriptCallback = (Result<Any?, Error>) -> Void

func callJavascript(webView: WKWebView?, javascriptString: String, callback: JavascriptCallback? = nil) {
    webView?.evaluateJavaScript(javascriptString) { (response, error) in
        if let error = error {
            callback?(.failure(error))
        }
        else {
            callback?(.success(response))
        }
    }
}

// 函数用于解析 CSS 并替换 `var()` 引用
func replaceCSSVariables(css: String) -> String {
    // 正则表达式用于匹配变量定义，例如 --sans-serif-font: ...
    let variablePattern = #"--([a-zA-Z0-9\-]+):\s*([^;]+);"#
    // 正则表达式用于匹配使用 var() 的地方
    let varPattern = #"var\(--([a-zA-Z0-9\-]+)\)"#

    var cssVariables = [String: String]()
    
    // 1. 提取变量定义并存入字典
    if let regex = try? NSRegularExpression(pattern: variablePattern, options: []) {
        let matches = regex.matches(in: css, options: [], range: NSRange(css.startIndex..., in: css))
        
        for match in matches {
            if let variableRange = Range(match.range(at: 1), in: css),
               let valueRange = Range(match.range(at: 2), in: css) {
                let variableName = String(css[variableRange])
                let variableValue = String(css[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 将变量存入字典
                cssVariables[variableName] = variableValue
            }
        }
    }

    // 2. 替换 var() 引用为字典中对应的值
    if let regex = try? NSRegularExpression(pattern: varPattern, options: []) {
        var modifiedCSS = css
        
        let matches = regex.matches(in: css, options: [], range: NSRange(css.startIndex..., in: css))
        for match in matches.reversed() {
            if let varNameRange = Range(match.range(at: 1), in: css) {
                let varName = String(css[varNameRange])
                
                // 查找对应的变量值
                if let value = cssVariables[varName] {
                    let fullMatchRange = Range(match.range, in: css)!
                    modifiedCSS.replaceSubrange(fullMatchRange, with: value)
                }
            }
        }
        
        return modifiedCSS
    }

    return css
}

enum ThemeStyle: String {
    case gzhDefault = "themes/gzh_default.css"
    case toutiaoDefault = "themes/toutiao_default.css"
    case zhihuDefault = "themes/zhihu_default.css"
    case juejinDefault = "themes/juejin_default.css"
    case orangeHeart = "themes/orangeheart.css"
    case rainbow = "themes/rainbow.css"
    case lapis = "themes/lapis.css"
    case pie = "themes/pie.css"
    case maize = "themes/maize.css"
    case purple = "themes/purple.css"
    
    var name: String {
        switch self {
        case .gzhDefault: "默认"
        case .toutiaoDefault: "默认"
        case .zhihuDefault: "默认"
        case .juejinDefault: "默认"
        case .orangeHeart: "Orange Heart"
        case .rainbow: "Rainbow"
        case .lapis: "Lapis"
        case .pie: "Pie"
        case .maize: "Maize"
        case .purple: "Purple"
        }
    }
    
    var author: String {
        switch self {
        case .gzhDefault: ""
        case .toutiaoDefault: ""
        case .zhihuDefault: ""
        case .juejinDefault: ""
        case .orangeHeart: "evgo2017"
        case .rainbow: "thezbm"
        case .lapis: "YiNN"
        case .pie: "kevinzhao2233"
        case .maize: "BEATREE"
        case .purple: "hliu202"
        }
    }
}

enum HighlightStyle: String {
    case idea = "highlight/styles/idea.min.css"
    case monokai = "highlight/styles/monokai.min.css"
    case github = "highlight/styles/github.min.css"
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
    
    var id: Self { self }
    
    var themes: [ThemeStyle] {
        switch self {
        case .gzh:
            return [.gzhDefault, .orangeHeart, .rainbow, .lapis, .pie, .maize, .purple]
        case .zhihu:
            return [.zhihuDefault]
        case .toutiao:
            return [.toutiaoDefault]
        case .juejin:
            return [.juejinDefault]
        }
    }
}
