//
//  DBHandler.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/20.
//

import Foundation
import CoreData

func fetchCustomThemes() throws -> [CustomTheme] {
    let context = CoreDataStack.shared.viewContext
    let fetchRequest: NSFetchRequest<CustomTheme> = CustomTheme.fetchRequest()
    return try context.fetch(fetchRequest)
}

func getCustomThemeById(id: String) throws -> CustomTheme? {
    return try fetchCustomThemes().filter { item in
        item.objectID.uriRepresentation().absoluteString == id
    }.first
}

func saveCustomTheme(name: String, content: String) throws -> CustomTheme {
    let context = CoreDataStack.shared.viewContext
    let customTheme = CustomTheme(context: context)
    customTheme.name = name
    customTheme.content = content
    customTheme.createdAt = Date()
    try CoreDataStack.shared.save(customTheme)
    return customTheme
}

func updateCustomTheme(customTheme: CustomTheme, name: String, content: String) throws {
    customTheme.name = name
    customTheme.content = content
    try CoreDataStack.shared.save(customTheme)
}

func deleteCustomTheme(_ customTheme: CustomTheme) throws {
    try CoreDataStack.shared.delete(customTheme)
}

func getUploadCache(md5: String) throws -> UploadCache? {
    try CoreDataStack.shared.get(UploadCache.self, by: "md5", value: md5)
}

func saveUploadCache(md5: String, url: String, mediaId: String) throws -> UploadCache {
    let context = CoreDataStack.shared.viewContext
    let uploadCache = UploadCache(context: context)
    uploadCache.md5 = md5
    uploadCache.url = url
    uploadCache.mediaId = mediaId
    uploadCache.createdAt = Date()
    try CoreDataStack.shared.save(uploadCache)
    return uploadCache
}

func clearUploadCache() throws {
    try CoreDataStack.shared.deleteAll(ofType: UploadCache.self)
}
