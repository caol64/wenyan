//
//  DBHandler.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/20.
//

import Foundation
import CoreData

func fetchCustomThemes() throws -> [CustomTheme] {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<CustomTheme> = CustomTheme.fetchRequest()
    return try context.fetch(fetchRequest)
}

func getCustomThemeById(id: String) throws -> CustomTheme? {
    return try fetchCustomThemes().filter { item in
        item.objectID.uriRepresentation().absoluteString == id
    }.first
}

func saveCustomTheme(name: String, content: String) throws -> CustomTheme {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let customTheme = CustomTheme(context: context)
    customTheme.name = name
    customTheme.content = content
    customTheme.createdAt = Date()
    try CoreDataStack.shared.save()
    return customTheme
}

func updateCustomTheme(customTheme: CustomTheme, name: String, content: String) throws {
    customTheme.name = name
    customTheme.content = content
    try CoreDataStack.shared.save()
}

func deleteCustomTheme(_ customTheme: CustomTheme) throws {
    try CoreDataStack.shared.delete(item: customTheme)
}
