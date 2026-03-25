//
//  TokenStore.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/24.
//

import Foundation

struct TokenData: Codable {
    var accessToken: String
    var expireAt: Int
    
    /// 校验 Token 是否有效
    func isValid() -> Bool {
        let currentTime = Int(Date().timeIntervalSince1970)
        let bufferTime: Int = 600 // 10分钟缓冲期
        return self.expireAt > currentTime + bufferTime
    }
}

// 字典结构，Key 为 appId
typealias WechatToken = [String: TokenData]

func getCachedToken(for appId: String) -> String? {
    guard let storedTokens = _getAllCachedTokens(),
          let tokenData = storedTokens[appId] else {
        return nil
    }
    
    if tokenData.isValid() {
        return tokenData.accessToken
    }
    
    removeCachedToken(for: appId)
    return nil
}

func saveCachedToken(appId: String, accessToken: String, expireAt: Int) {
    // 1. 先获取现有的所有 Token
    var allTokens = _getAllCachedTokens() ?? [:]
    
    // 2. 更新或插入当前 appId 的数据
    let newTokenData = TokenData(accessToken: accessToken, expireAt: expireAt)
    allTokens[appId] = newTokenData
    
    // 3. 将整个字典重新编码并保存
    if let encoded = try? JSONEncoder().encode(allTokens) {
        UserDefaults.standard.set(encoded, forKey: "wechatToken")
    }
}

func removeCachedToken(for appId: String) {
    guard var allTokens = _getAllCachedTokens() else { return }
    
    allTokens.removeValue(forKey: appId)
    
    if let encoded = try? JSONEncoder().encode(allTokens) {
        UserDefaults.standard.set(encoded, forKey: "wechatToken")
    }
}

func clearAllCachedTokens() {
    UserDefaults.standard.removeObject(forKey: "wechatToken")
}

/// 从 UserDefaults 读取完整的 Token 字典
private func _getAllCachedTokens() -> WechatToken? {
    if let savedData = UserDefaults.standard.data(forKey: "wechatToken"),
       let decoded = try? JSONDecoder().decode(WechatToken.self, from: savedData) {
        return decoded
    }
    return nil
}
