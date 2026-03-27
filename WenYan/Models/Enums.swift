//
//  Enums.swift
//  WenYan
//
//  Created by Lei Cao on 2024/11/27.
//

// MARK: - User Intents
enum UserAction {
    case changePlatform(Platform)
    case openSettings
    case setContent(String)
    case toggleFileSidebar
    case onError(String)
}

enum AppConstants {
    static let defaultAppName = "文颜"
}

enum Platform: String, CaseIterable, Identifiable {
    case wechat
    case toutiao
    case zhihu
    case juejin
    case medium
    
    var id: Self { self }

}
