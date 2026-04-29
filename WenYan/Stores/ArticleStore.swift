//
//  ArticleStore.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/25.
//

import Foundation

func loadArticle() -> String? {
    return UserDefaults.standard.string(forKey: "lastArticle")
}

func saveArticle(_ payload: String?) {
    UserDefaults.standard.set(payload, forKey: "lastArticle")
}

func setLastArticlePath(fileName: String, filePath: String, relativePath: String) {
    let info = ArticlePathInfo(fileName: fileName, filePath: filePath, relativePath: relativePath)
    
    if let encoded = try? JSONEncoder().encode(info) {
        UserDefaults.standard.set(encoded, forKey: "lastArticlePath")
    }
}

func resetLastArticlePath() {
    UserDefaults.standard.removeObject(forKey: "lastArticlePath")
}

func getLastArticleRelativePath() -> String? {
    guard let savedData = UserDefaults.standard.data(forKey: "lastArticlePath") else {
        return nil
    }
    guard let info = try? JSONDecoder().decode(ArticlePathInfo.self, from: savedData) else {
        return nil
    }
    return info.relativePath
}

func getLastArticleFilePath() -> URL? {
    guard let savedData = UserDefaults.standard.data(forKey: "lastArticlePath") else {
        return nil
    }
    guard let info = try? JSONDecoder().decode(ArticlePathInfo.self, from: savedData) else {
        return nil
    }
    return URL(fileURLWithPath: info.filePath)
}
