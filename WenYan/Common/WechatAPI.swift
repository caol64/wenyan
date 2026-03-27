//
//  WechatAPI.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/24.
//

import Foundation

struct AccessTokenResponse {
    var accessToken: String
    var expiresIn: Int
}

struct UploadResponse: Codable {
    var mediaId: String
    var url: String
}

private let tokenUrl = "https://api.weixin.qq.com/cgi-bin/token"
private let publishUrl = "https://api.weixin.qq.com/cgi-bin/draft/add"
private let uploadUrl = "https://api.weixin.qq.com/cgi-bin/material/add_material"

private func getAccessTokenWithCache() async throws -> String {
    guard getSettings()?.enabledImageHost == "wechat" else {
        throw AppError.bizError(description: "请先在设置中启用微信图床")
    }
    guard let credential = getCredential(), let appId = credential.appId, let appSecret = credential.appSecret else {
        throw AppError.bizError(description: "请先在设置中配置微信的凭据")
    }
    if let token = getCachedToken(for: appId) {
        return token
    } else {
        let newToken = try await fetchAccessToken(appId: appId, appSecret: appSecret)
        let currentTime = Int(Date().timeIntervalSince1970)
        let expireAt = currentTime + newToken.expiresIn
        saveCachedToken(appId: appId, accessToken: newToken.accessToken, expireAt: expireAt)
        return newToken.accessToken
    }
}

func uploadImageWithCache(fileData: Data, fileName: String, mimeType: String) async throws -> UploadResponse {
    guard getSettings()?.uploadSettings.autoCache == true else {
        return try await uploadImage(fileData: fileData, fileName: fileName, mimeType: mimeType)
    }
    let md5 = fileData.md5
    if let cached = try getUploadCache(md5: md5), let mediaId = cached.mediaId, let url = cached.url {
        return UploadResponse(mediaId: mediaId, url: url)
    }
    let response = try await uploadImage(fileData: fileData, fileName: fileName, mimeType: mimeType)
    let _ = try saveUploadCache(md5: md5, url: response.url, mediaId: response.mediaId)
    return response
}

private func uploadImage(fileData: Data, fileName: String, mimeType: String) async throws -> UploadResponse {
    try await uploadMaterial(type: "image", fileData: fileData, fileName: fileName, mimeType: mimeType)
}

func publishArticle(_ publishOptions: WechatPublishOptions) async throws -> String {
    let accessToken = try await getAccessTokenWithCache()
    let urlString = "\(publishUrl)?access_token=\(accessToken)"
    guard let url = URL(string: urlString) else {
        throw AppError.bizError(description: "微信接口地址配置错误")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    do {
        let payload = ["articles": [publishOptions]]
        let bodyData = try JSONEncoder().encode(payload)
        request.httpBody = bodyData
    } catch {
        throw AppError.bizError(description: "构建请求参数失败: \(error.localizedDescription)")
    }
    
    let data: Data
    do {
        (data, _) = try await URLSession.shared.data(for: request)
    } catch {
        throw AppError.networkError(description: error.localizedDescription)
    }
    let json: [String: Any]?
    do {
        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        throw AppError.bizError(description: "解析微信返回的数据失败")
    }
    
    if let mediaId = json?["media_id"] as? String {
        return mediaId
    } else if let errcode = json?["errcode"] as? Int,
              let errmsg = json?["errmsg"] as? String {
        throw AppError.bizError(description: "微信 API 错误: \(errcode): \(errmsg)")
    } else {
        throw AppError.bizError(description: "微信返回了未知的数据格式")
    }
}

private func fetchAccessToken(appId: String, appSecret: String) async throws -> AccessTokenResponse {
    let urlString = "\(tokenUrl)?grant_type=client_credential&appid=\(appId)&secret=\(appSecret)"
    guard let url = URL(string: urlString) else {
        throw AppError.bizError(description: "微信接口地址配置错误")
    }
    
    let data: Data
    do {
        (data, _) = try await URLSession.shared.data(from: url)
    } catch {
        throw AppError.networkError(description: error.localizedDescription)
    }
    
    let json: [String: Any]?
    do {
        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        throw AppError.bizError(description: "解析微信返回的数据失败")
    }
    
    if let accessToken = json?["access_token"] as? String,
       let expiresIn = json?["expires_in"] as? Int {
        return AccessTokenResponse(accessToken: accessToken, expiresIn: expiresIn)
    } else if let errcode = json?["errcode"] as? Int,
              let errmsg = json?["errmsg"] as? String {
        throw AppError.bizError(description: "微信 API 错误: \(errcode): \(errmsg)")
    } else {
        throw AppError.bizError(description: "微信返回了未知的数据格式")
    }
}

private func uploadMaterial(type: String, fileData: Data, fileName: String, mimeType: String) async throws -> UploadResponse {
    let accessToken = try await getAccessTokenWithCache()
    let urlString = "\(uploadUrl)?access_token=\(accessToken)&type=\(type)"
    guard let url = URL(string: urlString) else {
        throw AppError.bizError(description: "微信接口地址配置错误")
    }
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    let httpBody = createMultipartFormData(boundary: boundary, fileData: fileData, fileName: fileName, mimeType: mimeType)
    request.httpBody = httpBody
    
    let data: Data
    do {
        (data, _) = try await URLSession.shared.data(for: request)
    } catch {
        throw AppError.networkError(description: error.localizedDescription)
    }
    
    let json: [String: Any]?
    do {
        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        throw AppError.bizError(description: "解析微信返回的数据失败")
    }
    
    if let url = json?["url"] as? String,
       let mediaId = json?["media_id"] as? String {
        return UploadResponse(mediaId: mediaId, url: url.replacingOccurrences(of: "http://", with: "https://"))
    } else if let errcode = json?["errcode"] as? Int,
              let errmsg = json?["errmsg"] as? String {
        throw AppError.bizError(description: "微信 API 错误: \(errcode): \(errmsg)")
    } else {
        throw AppError.bizError(description: "微信返回了未知的数据格式")
    }
}

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
