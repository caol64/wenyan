//
//  Types.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import Foundation

struct JsCustomTheme: Codable {
    var id: String
    var name: String
    var css: String
}

struct ArticlePathInfo: Codable {
    let fileName: String
    let filePath: String
    let relativePath: String
}

struct WechatPublishOptions: Codable {
    let title: String
    let author: String?
    let content: String
    let thumb_media_id: String
    let content_source_url: String?
}
