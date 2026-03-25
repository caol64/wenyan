//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit
import UniformTypeIdentifiers

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
    DispatchQueue.main.async {
        webView?.evaluateJavaScript(javascriptString) { (response, error) in
            if let error = error {
                callback?(.failure(error))
            } else {
                callback?(.success(response))
            }
        }
    }
}

func callAsyncJavaScript(webView: WKWebView?, javascriptBody: String, args: [String: Any] = [:]) async throws -> Any? {
    return try await webView?.callAsyncJavaScript(
        javascriptBody,
        arguments: args,
        in: nil,
        contentWorld: .page
    )
}

func getAppinfo(for key: String) -> String? {
    return Bundle.main.infoDictionary?[key] as? String
}

func getAppName() -> String {
    return getAppinfo(for: "CFBundleDisplayName") ?? AppConstants.defaultAppName
}

func serializeToJSONString(_ object: Any?) -> String {
    guard let obj = object else {
        return "null" // 对应 JS 的 null
    }
    
    if let stringObj = obj as? String {
        // String 必须被包裹在双引号中，并转义内部的特殊字符
        // 使用 JSONSerialization 包装成数组，再剥离外壳，这是处理纯字符串最安全的黑科技
        if let data = try? JSONSerialization.data(withJSONObject: [stringObj], options:[]),
           let jsonStr = String(data: data, encoding: .utf8) {
            // jsonStr 此时是["你的字符串"]
            let start = jsonStr.index(jsonStr.startIndex, offsetBy: 1)
            let end = jsonStr.index(jsonStr.endIndex, offsetBy: -1)
            return String(jsonStr[start..<end]) // 剥去头尾的中括号，返回安全的 "你的字符串"
        }
        return "null" // 极端失败情况
    }
    
    if let boolObj = obj as? Bool {
        return boolObj ? "true" : "false"
    }
    
    if let numberObj = obj as? NSNumber {
        return numberObj.stringValue
    }
    
    if JSONSerialization.isValidJSONObject(obj),
       let data = try? JSONSerialization.data(withJSONObject: obj, options:[]),
       let jsonStr = String(data: data, encoding: .utf8) {
        return jsonStr
    }
    
    print("[JSBridge Warning] 无法序列化该类型的数据: \(type(of: obj))")
    return "null"
}

// 返回带 data:image/png;base64 前缀的 base64
func getDataURIFromFile(at url: URL) throws -> String? {
    let savedPaths = getAllSavedScopedURLs()
    if let matchedPath = url.findBestSecurityScopedPrefix(in: savedPaths) {
        // 从 path 找回原始的 Security Scoped URL
        let key = "Bookmark_\(matchedPath)"
        var isStale = false
        if let bookmarkData = UserDefaults.standard.data(forKey: key) {
            let workspaceURL = try URL(resolvingBookmarkData: bookmarkData,
                                       options: .withSecurityScope,
                                       relativeTo: nil,
                                       bookmarkDataIsStale: &isStale)
            if isStale {
                try saveSecurityScopedBookmark(for: workspaceURL)
            }
            if workspaceURL.startAccessingSecurityScopedResource() {
                defer { workspaceURL.stopAccessingSecurityScopedResource() }
                let data = try Data(contentsOf: url)
                let base64String = data.base64EncodedString()
                
                // 获取文件的 MIME 类型 (例如 image/png)
                let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
                
                return "data:\(mimeType);base64,\(base64String)"
            }
        }
    }
    throw AppError.bizError(description: "无文件访问权限：\(url.absoluteString)")
}

func saveSecurityScopedBookmark(for url: URL) throws {
    // 1. 生成 Bookmark 数据
    let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
    
    let path = url.path
    let bookmarkKey = "Bookmark_\(path)"
    let indexKey = "SavedBookmarkPaths"
    
    // 2. 存储具体的 Bookmark 数据
    UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
    
    // 3. 更新目录索引集合
    var savedPaths = UserDefaults.standard.stringArray(forKey: indexKey) ?? []
    
    if !savedPaths.contains(path) {
        savedPaths.append(path)
        UserDefaults.standard.set(savedPaths, forKey: indexKey)
    }
}

func getAllSavedScopedURLs() -> [String] {
    let indexKey = "SavedBookmarkPaths"
    guard let savedPaths = UserDefaults.standard.stringArray(forKey: indexKey) else {
        return []
    }
    
    return savedPaths
}

func getFileExtension(from mimeType: String) -> String {
    if let utType = UTType(mimeType: mimeType),
       let ext = utType.preferredFilenameExtension {
        return ext
    }
    return "png"
}

func getMimeType(from extension: String) -> String {
    let ext = `extension`.lowercased()
    
    if let utType = UTType(filenameExtension: ext),
       let mimeType = utType.preferredMIMEType {
        return mimeType
    }
    return "application/octet-stream"
}
