//
//  SecurityScopedResourceStore.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/26.
//

import Foundation

func saveSecurityScopedBookmark(for url: URL) throws {
    // 1. 生成 Bookmark 数据
    let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
    
    let path = url.path
    let bookmarkKey = "Bookmark_\(path)"
    let indexKey = "SavedBookmarkPaths"
    
    // 2. 存储具体的 Bookmark 数据
    UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
    
    // 3. 更新目录索引集合
    var savedPaths = UserDefaults.standard.stringArray(forKey: indexKey) ?? []
    
    if !savedPaths.contains(path) {
        savedPaths.append(path)
        UserDefaults.standard.set(savedPaths, forKey: indexKey)
    }
}

func getAllSavedScopedURLs() -> [String] {
    let indexKey = "SavedBookmarkPaths"
    guard let savedPaths = UserDefaults.standard.stringArray(forKey: indexKey) else {
        return []
    }
    
    return savedPaths
}

func getBookmark(path: String) -> Data? {
    let bookmarkKey = "Bookmark_\(path)"
    return UserDefaults.standard.data(forKey: bookmarkKey)
}

/// 在安全作用域内执行特定的文件操作（读、写等）
/// - Parameters:
///   - url: 目标文件或目录的 URL
///   - action: 获取权限后要执行的闭包
/// - Returns: 闭包执行的结果
func performWithSecurityScope<T>(for url: URL, action: () throws -> T) throws -> T {
    // 1. 查找是否有匹配的已授权目录前缀
    let savedPaths = getAllSavedScopedURLs()
    guard let matchedPath = url.findBestSecurityScopedPrefix(in: savedPaths) else {
        throw AppError.bizError(description: "未找到该文件所在目录的访问权限：\(url.path)")
    }
    
    // 2. 从 UserDefaults 中读取该目录的书签数据
    guard let bookmarkData = getBookmark(path: matchedPath) else {
        throw AppError.bizError(description: "书签数据丢失，请重新授权目录：\(matchedPath)")
    }
    
    var isStale = false
    // 3. 解析书签还原出受保护的目录 URL
    let workspaceURL = try URL(resolvingBookmarkData: bookmarkData,
                               options: .withSecurityScope,
                               relativeTo: nil,
                               bookmarkDataIsStale: &isStale)
    
    // 如果书签数据陈旧，重新保存一次以更新状态
    if isStale {
        try saveSecurityScopedBookmark(for: workspaceURL)
    }
    
    // 4. 声明开始访问该安全资源
    guard workspaceURL.startAccessingSecurityScopedResource() else {
        throw AppError.bizError(description: "系统拒绝了对该目录的安全访问：\(workspaceURL.path)")
    }
    
    // 5. 离开作用域时，必须停止访问，防止内核资源泄漏
    defer {
        workspaceURL.stopAccessingSecurityScopedResource()
    }
    
    // 6. 在已授权的上下文中，执行传入的闭包（读/写操作都在这里发生）
    return try action()
}
