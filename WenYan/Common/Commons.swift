//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit

func getResourceBundle() -> URL? {
    return Bundle.main.url(forResource: "Resources", withExtension: "bundle")
}

func loadFile(_ path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: .utf8)
}

func loadFileFromResource(path: String) throws -> String {
    let nsPath = path as NSString
    let path = nsPath.deletingPathExtension
    let `extension` = nsPath.pathExtension
    return try loadFileFromResource(forResource: path, withExtension: `extension`)
}

func loadFileFromResource(forResource: String, withExtension: String) throws -> String {
    guard
        let resourceBundleURL = getResourceBundle(),
        let resourceBundle = Bundle(url: resourceBundleURL),
        let filePath = resourceBundle.path(forResource: forResource, ofType: withExtension)
    else {
        throw AppError.bizError(description: "Required resource is missing")
    }
    return try loadFile(filePath)
}

typealias JavascriptCallback = (Result<Any?, Error>) -> Void

func callJavascript(webView: WKWebView?, javascriptString: String, callback: JavascriptCallback? = nil) {
    webView?.evaluateJavaScript(javascriptString) { (response, error) in
        if let error = error {
            callback?(.failure(error))
        } else {
            callback?(.success(response))
        }
    }
}

func callAsyncJavaScript(webView: WKWebView?, javascriptBody: String, args: [String: Any] = [:]) async throws -> Any? {
    return try await webView?.callAsyncJavaScript(
        javascriptBody,
        arguments: args,
        in: nil,
        contentWorld: .page
    )
}

func getAppinfo(for key: String) -> String? {
    return Bundle.main.infoDictionary?[key] as? String
}

func getAppName() -> String {
    return getAppinfo(for: "CFBundleDisplayName") ?? AppConstants.defaultAppName
}

func fetchCustomThemes() throws -> [CustomTheme] {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<CustomTheme> = CustomTheme.fetchRequest()
    return try context.fetch(fetchRequest)
}

func deleteCustomTheme(_ customTheme: CustomTheme) throws {
    try CoreDataStack.shared.delete(item: customTheme)
}

func saveCustomTheme(content: String) throws -> CustomTheme {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let customTheme = CustomTheme(context: context)
    customTheme.name = "自定义主题"
    customTheme.content = content
    customTheme.createdAt = Date()
    try CoreDataStack.shared.save()
    return customTheme
}

func updateCustomTheme(customTheme: CustomTheme, content: String) throws {
    customTheme.content = content
    try CoreDataStack.shared.save()
}

// MARK: - Upload
func uploadImage(_ fileData: Data, name: String, type: String) async throws -> String {
    guard let hostID = UserDefaults.standard.string(forKey: "ebabledImageHost"), !hostID.isEmpty else {
        throw AppError.bizError(description: "未启用图床")
    }
    guard hostID == Settings.ImageHosts.gzh.id else {
        throw AppError.bizError(description: "暂不支持该图床")
    }

    guard let savedData = UserDefaults.standard.data(forKey: "gzhImageHost"),
        let config = try? JSONDecoder().decode(GzhImageHost.self, from: savedData),
        let uploader = UploaderFactory.createUploader(config: config)
    else {
        throw AppError.bizError(description: "图床配置错误")
    }

    guard let url = try await uploader.upload(fileData: fileData, fileName: name, mimeType: type) else {
        throw AppError.bizError(description: "上传失败")
    }
    return url.replacingOccurrences(of: "http://", with: "https://")
}
