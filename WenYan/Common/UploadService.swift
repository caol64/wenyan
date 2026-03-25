//
//  UploadService.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/25.
//

import Foundation

// MARK: - 核心上传逻辑
/// 将任意格式的图片来源（URL/本地/Base64）解析并上传至微信公众号
/// - Parameter source: 图片的来源字符串（可以是 http 链接、file 路径或 data:base64 字符串）
/// - Returns: 微信 API 返回的上传响应对象
func uploadImageToWechat(from source: String) async throws -> UploadResponse {
    let fileData: Data
    let fileName: String
    let mimetype: String
    
    if source.hasPrefix("http://") || source.hasPrefix("https://") {
        // 1. 处理网络图片
        guard let url = URL(string: source) else {
            throw NSError(domain: "ImageError", code: -1, userInfo:[NSLocalizedDescriptionKey: "无效的网络图片链接"])
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        fileData = data
        fileName = url.lastPathComponent
        mimetype = response.mimeType ?? WenYan.getMimeType(from: url.pathExtension)
        
    } else if source.hasPrefix("data:") {
        // 2. 处理 Base64 (Data URI)
        let components = source.components(separatedBy: ",")
        guard components.count == 2,
              let header = components.first,
              let base64String = components.last,
              // Data(base64Encoded:) 能够自动处理换行符等噪音
              let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base64 图片数据解析失败"])
        }
        
        fileData = data
        
        // 正则提取头部的 MIME Type
        if let regex = try? NSRegularExpression(pattern: "data:(.*?);"),
           let match = regex.firstMatch(in: header, range: NSRange(location: 0, length: header.utf16.count)) {
            mimetype = (header as NSString).substring(with: match.range(at: 1))
        } else {
            mimetype = "image/png"
        }
        
        let ext = WenYan.getFileExtension(from: mimetype)
        fileName = "upload_image_\(Int(Date().timeIntervalSince1970)).\(ext)"
        
    } else {
        // 3. 处理本地图片绝对路径
        let url = URL(fileURLWithPath: source)
        // 这里如果是沙盒模式读取外部文件，需要提前处理 Bookmark 权限
        fileData = try Data(contentsOf: url)
        fileName = url.lastPathComponent
        mimetype = WenYan.getMimeType(from: url.pathExtension)
    }
    
    return try await uploadImage(fileData: fileData, fileName: fileName, mimeType: mimetype)
}

func uploadAndReplaceImagesInMarkdown(markdown: String, predicate: (String) -> Bool) async -> String {
    var processingText = markdown
    
    // ==========================================
    // 1. 保护特殊区域 (Frontmatter, 代码块, 行内代码)
    // ==========================================
    // 正则解析：
    // ^(?:---[\\s\\S]*?\\n---) : 匹配开头可能存在的 Frontmatter
    // ```[\\s\\S]*?```        : 匹配多行代码块
    // `[^`]+`                  : 匹配行内代码
    let protectedPattern = "^(?:---[\\s\\S]*?\\n---)|```[\\s\\S]*?```|`[^`]+`"
    guard let protectedRegex = try? NSRegularExpression(pattern: protectedPattern, options: []) else {
        return markdown
    }
    
    var protectedMap: [String: String] = [:]
    var placeholderCount = 0
    
    let nsOriginalText = processingText as NSString
    let protectedMatches = protectedRegex.matches(in: processingText, options:[], range: NSRange(location: 0, length: nsOriginalText.length))
    
    // 关键：必须从后往前 (reversed) 替换！
    // 因为修改前面的字符串会导致后面匹配的 Range 坐标发生偏移失效。
    for match in protectedMatches.reversed() {
        let nsText = processingText as NSString
        let originalBlock = nsText.substring(with: match.range)
        
        let placeholder = "__WENYAN_PROTECTED_\(placeholderCount)__"
        protectedMap[placeholder] = originalBlock
        
        processingText = nsText.replacingCharacters(in: match.range, with: placeholder)
        placeholderCount += 1
    }
    
    // ==========================================
    // 2. 在安全区域内匹配真实图片
    // ==========================================
    // 匹配: ![alt](url) 或 ![alt](url "title")
    // Group 1: alt text  Group 2: url  Group 3: 空格和title
    let imagePattern = "!\\[([^\\]]*)\\]\\(\\s*([^\"\\s)]+)([^)]*)\\)"
    guard let imageRegex = try? NSRegularExpression(pattern: imagePattern, options:[]) else {
        return restoreProtectedBlocks(text: processingText, map: protectedMap)
    }
    
    let nsSafeText = processingText as NSString
    let imageMatches = imageRegex.matches(in: processingText, options:[], range: NSRange(location: 0, length: nsSafeText.length))
    
    // 提取需要上传的 URL（使用 Set 去重，避免一张图反复上传）
    var urlsToUpload: Set<String> = []
    for match in imageMatches {
        let urlRange = match.range(at: 2) // 取第 2 个括号的匹配内容 (URL)
        if urlRange.location != NSNotFound {
            let src = nsSafeText.substring(with: urlRange)
            if predicate(src) {
                urlsToUpload.insert(src)
            }
        }
    }
    
    if urlsToUpload.isEmpty {
        // 没有需要处理的图片，直接还原保护区返回
        return restoreProtectedBlocks(text: processingText, map: protectedMap)
    }
    
    // ==========================================
    // 3. 遍历并执行异步上传
    // ==========================================
    let relativePath = getLastArticleRelativePath() // 假定这个函数外部存在
    var uploadedUrlsMap: [String: String] = [:]
    
    for oldSrc in urlsToUpload {
        let resolvedSrc = resolveRelativePath(path: oldSrc, relative: relativePath)
        
        do {
            let resp = try await uploadImageToWechat(from: resolvedSrc)
            uploadedUrlsMap[oldSrc] = resp.url
        } catch {
            print("Image upload failed: \(oldSrc), error: \(error.localizedDescription)")
            // 失败时跳过，保留原本的图片路径
        }
    }
    
    // ==========================================
    // 4. 将新 URL 替换回文本中 (精准 Range 替换)
    // ==========================================
    // 再次从后往前遍历替换，只替换 URL 所在的那个精确的 Range
    // 这样完美保留了用户的 alt 文本、以及可能存在的 title 悬停提示
    for match in imageMatches.reversed() {
        let urlRange = match.range(at: 2)
        if urlRange.location != NSNotFound {
            let nsCurrentText = processingText as NSString
            let oldSrc = nsCurrentText.substring(with: urlRange)
            
            if let newUrl = uploadedUrlsMap[oldSrc] {
                processingText = nsCurrentText.replacingCharacters(in: urlRange, with: newUrl)
            }
        }
    }
    
    // ==========================================
    // 5. 还原保护区并返回最终结果
    // ==========================================
    return restoreProtectedBlocks(text: processingText, map: protectedMap)
}

/// 辅助方法：将保护占位符替换回原始文本
private func restoreProtectedBlocks(text: String, map: [String: String]) -> String {
    var restoredText = text
    for (placeholder, originalBlock) in map {
        restoredText = restoredText.replacingOccurrences(of: placeholder, with: originalBlock)
    }
    return restoredText
}

/// 解析并返回最终的文件路径
/// - Parameters:
///   - path: 需要解析的路径（可以是网络链接、绝对路径或相对路径）
///   - relative: 可选的基准路径（比如当前 Markdown 文件的绝对路径或所在目录）
/// - Returns: 完整的路径字符串
func resolveRelativePath(path: String, relative: String? = nil) -> String {
    // 1. 如果是网络链接，直接返回
    if path.hasPrefix("http://") || path.hasPrefix("https://") {
        return path
    }
    
    // 2. 如果已经是绝对路径，标准化后直接返回
    let nsPath = path as NSString
    if nsPath.isAbsolutePath {
        // .standardizedPath 会自动解析掉里面的 "./" 或 "../"
        return nsPath.standardizingPath
    }
    
    // 3. 如果提供了基准路径 (relative)，则将其作为前缀与相对路径拼接
    if let base = relative {
        return getAbsoluteImagePath(basePath: base, relativePath: path)
    }
    
    // 4. 其他情况（相对路径但没有基准路径），直接返回原字符串
    return path
}

/// 根据基准路径和相对路径，计算出最终的绝对路径
/// - Parameters:
///   - basePath: 基准目录路径
///   - relativePath: 相对文件路径
/// - Returns: 标准化后的完整绝对路径
func getAbsoluteImagePath(basePath: String, relativePath: String) -> String {
    let baseURL = URL(fileURLWithPath: basePath)
    
    // 如果 basePath 传入的是一个文件（例如 /Users/lei/doc.md），我们需要获取它的父目录
    // 如果 basePath 本身就是目录（如 /Users/lei/），则直接使用
    let directoryURL = baseURL.hasDirectoryPath ? baseURL : baseURL.deletingLastPathComponent()
    
    // 拼接相对路径，并标准化（去除多余的斜杠、./、../ 等）
    let absoluteURL = directoryURL.appendingPathComponent(relativePath).standardizedFileURL
    
    return absoluteURL.path
}
