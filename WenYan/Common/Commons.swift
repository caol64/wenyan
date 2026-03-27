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
    
    // 1. 处理基础类型 (String, Bool, Number)
    if let stringObj = obj as? String {
        if let data = try? JSONSerialization.data(withJSONObject:[stringObj], options:[]),
           let jsonStr = String(data: data, encoding: .utf8) {
            let start = jsonStr.index(jsonStr.startIndex, offsetBy: 1)
            let end = jsonStr.index(jsonStr.endIndex, offsetBy: -1)
            return String(jsonStr[start..<end])
        }
        return "null"
    }
    
    if let boolObj = obj as? Bool {
        return boolObj ? "true" : "false"
    }
    
    if let numberObj = obj as? NSNumber {
        return numberObj.stringValue
    }
    
    // 2. 处理原生 Swift 的 Codable/Encodable 结构体
    if let encodableObj = obj as? any Encodable {
        if let data = try? JSONEncoder().encode(encodableObj),
           let jsonStr = String(data: data, encoding: .utf8) {
            return jsonStr
        }
    }
    
    // 3. 兜底处理 Objective-C 时代的动态集合 (如 [String: Any])
    // 因为[String: Any] 里的 Any 不遵循 Encodable，所以它会跳过第 2 步，在这里被正确处理
    if JSONSerialization.isValidJSONObject(obj),
       let data = try? JSONSerialization.data(withJSONObject: obj, options:[]),
       let jsonStr = String(data: data, encoding: .utf8) {
        return jsonStr
    }
    
    print("[JSBridge Warning] 无法序列化该类型的数据: \(type(of: obj))")
    return "null"
}

// 返回带 data:image/png;base64 前缀的 base64
func getDataURIFromFile(at url: URL) throws -> String {
    // 1. 调用通用方法安全地获取文件数据
    let data = try readDataWithSecurityScope(from: url)
    
    // 2. 将二进制数据编码为 Base64
    let base64String = data.base64EncodedString()
    
    // 3. 获取文件的 MIME 类型
    let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "image/png"
    
    // 4. 拼接 Data URI 格式并返回
    return "data:\(mimeType);base64,\(base64String)"
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

// MARK: - 通用文件读取 (沙盒权限)

/// 尝试使用已保存的安全作用域书签（Security-Scoped Bookmark）读取本地文件
/// - Parameter url: 要读取的目标文件 URL
/// - Returns: 文件的二进制数据 (Data)
/// - Throws: 如果没有权限、书签解析失败或文件读取失败，则抛出错误
func readDataWithSecurityScope(from url: URL) throws -> Data {
    // 1. 查找是否有匹配的已授权目录前缀
    let savedPaths = getAllSavedScopedURLs()
    guard let matchedPath = url.findBestSecurityScopedPrefix(in: savedPaths) else {
        throw AppError.bizError(description: "未找到该文件所在目录的访问权限：\(url.path)")
    }
    
    // 2. 从 UserDefaults 中读取该目录的书签数据
    guard let bookmarkData = getBookmark(path: matchedPath) else {
        throw AppError.bizError(description: "书签数据丢失，请重新授权目录：\(matchedPath)")
    }
    
    var isStale = false
    // 3. 解析书签还原出受保护的目录 URL
    let workspaceURL = try URL(resolvingBookmarkData: bookmarkData,
                               options: .withSecurityScope,
                               relativeTo: nil,
                               bookmarkDataIsStale: &isStale)
    
    // 如果书签数据陈旧（例如文件被移动过），重新保存一次以更新状态
    if isStale {
        try saveSecurityScopedBookmark(for: workspaceURL)
    }
    
    // 4. 声明开始访问该安全资源
    guard workspaceURL.startAccessingSecurityScopedResource() else {
        throw AppError.bizError(description: "系统拒绝了对该目录的安全访问：\(workspaceURL.path)")
    }
    
    // 5. 离开作用域时，必须停止访问，防止内核资源泄漏
    defer {
        workspaceURL.stopAccessingSecurityScopedResource()
    }
    
    // 6. 在已授权的上下文中，安全地读取目标文件的数据
    return try Data(contentsOf: url)
}
