//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit

struct WebkitStatus {
    static let isReady = "isReady"
    static let textContentDidChange = "textContentDidChange"
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

enum ThemeStyle: String {
    case gzhDefault = "themes/gzh_default.css"
    case toutiaoDefault = "themes/toutiao_default.css"
    case zhihuDefault = "themes/zhihu_default.css"
    case juejinDefault = "themes/juejin_default.css"
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
            return [.gzhDefault]
        case .zhihu:
            return [.zhihuDefault]
        case .toutiao:
            return [.toutiaoDefault]
        case .juejin:
            return [.juejinDefault]
        }
    }
}
