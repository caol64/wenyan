//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit

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

// MARK: - Upload
func uploadImage(_ fileData: Data, name: String, type: String) async throws -> String {
    guard let hostID = UserDefaults.standard.string(forKey: "ebabledImageHost"), !hostID.isEmpty else {
        throw AppError.bizError(description: "未启用图床")
    }
    guard hostID == Settings.ImageHosts.gzh.id else {
        throw AppError.bizError(description: "暂不支持该图床")
    }

    guard let savedData = UserDefaults.standard.data(forKey: "gzhImageHost"),
        let config = try? JSONDecoder().decode(GzhImageHost.self, from: savedData),
        let uploader = UploaderFactory.createUploader(config: config)
    else {
        throw AppError.bizError(description: "图床配置错误")
    }

    guard let url = try await uploader.upload(fileData: fileData, fileName: name, mimeType: type) else {
        throw AppError.bizError(description: "上传失败")
    }
    return url.replacingOccurrences(of: "http://", with: "https://")
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
