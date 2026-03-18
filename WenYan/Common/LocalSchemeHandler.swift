//
//  LocalSchemeHandler.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import Foundation
import WebKit
import UniformTypeIdentifiers

class LocalSchemeHandler: NSObject, WKURLSchemeHandler {
    
    // 拦截请求并返回本地文件数据
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }
        
        // 解析路径，例如 "app://_app/immutable/entry/start.js" -> "/_app/immutable/entry/start.js"
        var path = url.path
        if path.isEmpty || path == "/" {
            path = "/index.html" // 默认访问 index.html
        }
        
        // 去掉开头的 "/" 以便在 Bundle 中查找
        if path.hasPrefix("/") {
            path.removeFirst()
        }
        
        guard let resourceBundleURL = getResourceBundle(),
              let resourceBundle = Bundle(url: resourceBundleURL),
              let fileURL = resourceBundle.url(forResource: path, withExtension: nil) else {
            // 如果文件没找到，返回 404
            let error = NSError(domain: "LocalSchemeHandler", code: 404, userInfo: nil)
            urlSchemeTask.didFailWithError(error)
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let mimeType = getMimeType(for: fileURL.pathExtension)
            let response = URLResponse(url: url,
                                       mimeType: mimeType,
                                       expectedContentLength: data.count,
                                       textEncodingName: "utf-8")
            
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // 请求被取消时的处理（通常不需要写逻辑）
    }
    
    private func getMimeType(for extension: String) -> String {
        switch `extension`.lowercased() {
        case "html": return "text/html"
        case "js", "mjs": return "application/javascript"
        case "css": return "text/css"
        case "json": return "application/json"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg": return "image/svg+xml"
        case "woff2": return "font/woff2"
        default: return "application/octet-stream"
        }
    }
}
