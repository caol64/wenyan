//
//  CredentialStore.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/24.
//

import Foundation

struct GenericCredential: Codable {
    var type = "wechat"
    var appId: String?
    var appSecret: String?
}

func getCredential() -> GenericCredential? {
    if let savedData = UserDefaults.standard.data(forKey: "wenyanCredential"),
       let decoded = try? JSONDecoder().decode(GenericCredential.self, from: savedData) {
        return decoded
    }
    // 兼容老数据
    var data = GenericCredential()
    if let savedData = UserDefaults.standard.data(forKey: "gzhImageHost"),
       let jsonObject = try? JSONSerialization.jsonObject(with: savedData, options:[]),
       let dict = jsonObject as? [String: Any] {
        
        if let appId = dict["appId"] as? String, !appId.isEmpty {
            data.appId = appId
        }
        
        if let appSecret = dict["appSecret"] as? String, !appSecret.isEmpty {
            data.appSecret = appSecret
        }
        UserDefaults.standard.removeObject(forKey: "gzhImageHost")
    }
    saveCredential(credential: data)
    return data
}

func saveCredential(credential: GenericCredential) {
    if let encoded = try? JSONEncoder().encode(credential) {
        UserDefaults.standard.set(encoded, forKey: "wenyanCredential")
    }
}
