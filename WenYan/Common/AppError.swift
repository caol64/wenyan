//
//  AppError.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/24.
//

import Foundation

enum AppError: LocalizedError {
    case bizError(description: String)
    case networkError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .bizError(let description): return description
        case .networkError(let description): return "网络请求失败: \(description)"
        }
    }
}
