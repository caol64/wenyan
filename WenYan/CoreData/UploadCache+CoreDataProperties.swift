//
//  UploadCache+CoreDataProperties.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/26.
//
//

public import Foundation
public import CoreData


public typealias UploadCacheCoreDataPropertiesSet = NSSet

extension UploadCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UploadCache> {
        return NSFetchRequest<UploadCache>(entityName: "UploadCache")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var md5: String?
    @NSManaged public var mediaId: String?
    @NSManaged public var url: String?

}

extension UploadCache : Identifiable {

}
