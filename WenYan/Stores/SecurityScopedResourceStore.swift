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
