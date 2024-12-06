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

}
