//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit
import UniformTypeIdentifiers
import SwiftUI
import JavaScriptCore

struct WebkitStatus {
    static let loadHandler = "loadHandler"
    static let contentChangeHandler = "contentChangeHandler"
    static let scrollHandler = "scrollHandler"
    static let clickHandler = "clickHandler"
    static let errorHandler = "errorHandler"
    static let uploadHandler = "uploadHandler"
    static let loadThemesHandler = "loadThemesHandler"
    static let copyContentHandler = "copyContentHandler"
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
        } else {
            callback?(.success(response))
        }
    }
}

struct DataFile: FileDocument {
    static var readableContentTypes: [UTType] { [.jpeg, .pdf] }
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

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

func getAppinfo(for key: String) -> String? {
    return Bundle.main.infoDictionary?[key] as? String
}

func getAppName() -> String {
    return getAppinfo(for: "CFBundleDisplayName") ?? AppConstants.defaultAppName
}

extension UTType {
    static var md: UTType {
        UTType(importedAs: "com.yztech.WenYan.markdown")
    }
    static var css: UTType {
        UTType(importedAs: "com.yztech.WenYan.stylesheet")
    }
}

extension Link {
    func pointingHandCursor() -> some View {
        self.onHover { inside in
            if inside {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

// 扩展 WKWebView 添加 PDF 导出支持
extension WKWebView {
    func exportPDF(completion: @escaping (Data?, Error?) -> Void) {
        let pdfConfiguration = WKPDFConfiguration()
        self.createPDF(configuration: pdfConfiguration) { result in
            switch result {
            case .success(let pdfData):
                completion(pdfData, nil)
            case .failure(let error):
                completion(nil, error)
            }
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
