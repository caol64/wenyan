//
//  Uploader.swift
//  WenYan
//
//  Created by Lei Cao on 2025/2/19.
//

import Foundation

protocol Uploader {
    func upload(fileData: Data, fileName: String, mimeType: String) async throws -> String?
}

class UploaderFactory {
    static func createUploader(config: Codable) -> Uploader? {
        switch config {
        case let gzhConfig as GzhImageHost:
            return GzhUploader(config: gzhConfig)
        default:
            return nil
        }
    }
}
