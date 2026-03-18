//
//  CustomTheme+CoreDataProperties.swift
//  WenYan
//
//  Created by Lei Cao on 2024/10/24.
//
//

import Foundation
import CoreData


extension CustomTheme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomTheme> {
        return NSFetchRequest<CustomTheme>(entityName: "CustomTheme")
    }

    @NSManaged public var name: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?

}

extension CustomTheme : Identifiable {
    func toDictionary() -> [String: Any] {
        var dict:[String: Any] = [:]
        
        dict["name"] = self.name ?? ""
        dict["content"] = self.content ?? ""
        
        if let date = self.createdAt {
            dict["createdAt"] = Int(date.timeIntervalSince1970 * 1000)
        } else {
            dict["createdAt"] = NSNull() // 如果没有时间，传 null 给 JS
        }
        
        dict["id"] = self.objectID.uriRepresentation().absoluteString
        
        return dict
    }
}
