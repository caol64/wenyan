//
//  AppError.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/24.
//

import Foundation

enum AppError: LocalizedError {
    case bizError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .bizError(let description):
            return description
        }
    }
}
