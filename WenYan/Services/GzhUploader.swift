//
//  GzhUploader.swift
//  WenYan
//
//  Created by Lei Cao on 2025/2/19.
//

import Foundation

struct GzhImageHost: Codable {
    var type: String = ImageHosts.gzh.id
    var appId: String = ""
    var appSecret: String = ""
    var accessToken: String = ""
    var expireTime: Date?
}

class GzhUploader: Uploader {
    private var config: GzhImageHost

    init(config: GzhImageHost) {
        self.config = config
    }

    func upload(fileData: Data, fileName: String, mimeType: String) async throws -> String? {
        let needRefreshAccessToken = config.expireTime == nil || Date() > config.expireTime ?? Date()
        if needRefreshAccessToken {
            var accessToken = AccessToken(appId: config.appId, appSecret: config.appSecret)
            accessToken = try await accessToken.fetchAccessToken()
            config.accessToken = accessToken.accessToken ?? ""
            config.expireTime = Date().addingTimeInterval(TimeInterval(accessToken.expiresIn ?? 0))
            if let encoded = try? JSONEncoder().encode(config) {
                UserDefaults.standard.set(encoded, forKey: "gzhImageHost")
            }
        }
        let weChatMaterialUploader = WeChatMaterialUploader(accessToken: config.accessToken)
        let url = try await weChatMaterialUploader.uploadImage(fileData: fileData, fileName: fileName, mimeType: mimeType)
        return url
    }
}

class AccessToken {
    let appId: String
    let appSecret: String
    let apiUrl = "https://api.weixin.qq.com/cgi-bin/token"
    var accessToken: String?
    var expiresIn: Int?

    init(appId: String, appSecret: String) {
        self.appId = appId
        self.appSecret = appSecret
    }

    /// 获取 access_token
    func fetchAccessToken() async throws -> AccessToken {
        let urlString = "\(apiUrl)?grant_type=client_credential&appid=\(appId)&secret=\(appSecret)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        if let accessToken = json?["access_token"] as? String,
           let expiresIn = json?["expires_in"] as? Int {
            self.accessToken = accessToken
            self.expiresIn = expiresIn
            return self
        } else if let errcode = json?["errcode"] as? Int,
                  let errmsg = json?["errmsg"] as? String {
            throw NSError(domain: "WeChat API Error", code: errcode, userInfo: [NSLocalizedDescriptionKey: errmsg])
        } else {
            throw NSError(domain: "Unknown Error", code: -1, userInfo: nil)
        }
    }
}

class WeChatMaterialUploader {
    let accessToken: String
    let apiUrl = "https://api.weixin.qq.com/cgi-bin/material/add_material"

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    /// 上传素材
    func uploadMaterial(type: String, fileData: Data, fileName: String, mimeType: String) async throws -> String? {
        let urlString = "\(apiUrl)?access_token=\(accessToken)&type=\(type)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = createMultipartFormData(boundary: boundary, fileData: fileData, fileName: fileName, mimeType: mimeType)
        request.httpBody = httpBody

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        if let errcode = json?["errcode"] as? Int,
           let errmsg = json?["errmsg"] as? String {
            throw NSError(domain: "WeChat API Error", code: errcode, userInfo: [NSLocalizedDescriptionKey: errmsg])
        }

        return json?["url"] as? String
    }

    /// 上传图片
    func uploadImage(fileData: Data, fileName: String, mimeType: String) async throws -> String? {
        return try await uploadMaterial(type: "image", fileData: fileData, fileName: fileName, mimeType: mimeType)
    }

    /// 创建 multipart/form-data 请求体
    private func createMultipartFormData(boundary: String, fileData: Data, fileName: String, mimeType: String) -> Data {
        var body = Data()

        // 添加文件数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // 结束标记
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
