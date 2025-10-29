//
//  Extensions.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import WebKit


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

extension Error {
    func handle(in appState: AppState, fallback: String? = nil) {
        if let appError = self as? AppError {
            Task { @MainActor in
                appState.appError = appError
            }
        } else {
            let message = self.localizedDescription
            Task { @MainActor in
                appState.appError = .bizError(description: fallback ?? message)
            }
        }
    }
}
