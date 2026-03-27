//
//  CoreDataStack.swift
//  WenYan
//
//  Created by Lei Cao on 2024/10/24.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Singleton
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WenYan")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Core Data 存储描述符初始化失败")
        }
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data 加载失败: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Save Operations
    
    /// 保存当前上下文中的所有更改（包含新增、修改、删除的对象）
    /// 无论是新建了一个对象，还是修改了已查询出的对象的属性，最后都需要调用此方法。
    func saveContext() throws {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Core Data 保存失败: \(nserror), \(nserror.userInfo)")
            throw error
        }
    }
    
    /// 语义化：保存单个对象的修改（本质上依然是保存其所在的上下文）
    /// - Parameter item: 修改或创建的 NSManagedObject 对象
    func save(_ item: NSManagedObject) throws {
        // 如果该对象有关联的 Context，则保存该 Context；否则默认使用 viewContext
        let context = item.managedObjectContext ?? viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Delete Operations
    
    func delete(_ item: NSManagedObject) throws {
        let context = item.managedObjectContext ?? viewContext
        context.delete(item)
        if context.hasChanges {
            try context.save()
        }
    }
    
    func deleteAll<T: NSManagedObject>(ofType type: T.Type) throws {
        let context = viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            // 批量删除是直接操作数据库底层的，为了让内存中的 Context 知道数据被删了，需要重置
            context.reset()
        } catch {
            print("批量删除 \(type) 失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Fetch (Get) Operations
    
    /// 获取泛型实体的所有数据，或根据条件过滤出列表
    /// - Parameters:
    ///   - type: 实体的类型，例如 CustomTheme.self
    ///   - predicate: 过滤条件，默认 nil 表示获取全部
    ///   - sortDescriptors: 排序规则，默认 nil
    /// - Returns: 符合条件的实体数组
    func fetch<T: NSManagedObject>(_ type: T.Type,
                                   predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor]? = nil) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return try viewContext.fetch(request)
    }
    
    /// 根据条件获取单个对象
    /// 如果数据库中有多个符合条件的对象，只返回找到的第一个；如果没有则返回 nil。
    /// - Parameters:
    ///   - type: 实体的类型，例如 CustomTheme.self
    ///   - predicate: 查询条件（通常是匹配唯一 ID）
    /// - Returns: 找到的实体对象，未找到返回 nil
    func get<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate) throws -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.fetchLimit = 1 // 告诉底层数据库只要找到1条就立刻返回，提升性能
        
        let results = try viewContext.fetch(request)
        return results.first
    }
    
    /// 根据属性名和对应的值查询唯一的对象
    /// - Parameters:
    ///   - type: 实体的类型
    ///   - key: 属性名，例如 "id" 或 "uuid"
    ///   - value: 对应的值
    /// - Returns: 匹配的对象，若无则返回 nil
    func get<T: NSManagedObject, V: CVarArg>(_ type: T.Type, by key: String, value: V) throws -> T? {
        let predicate = NSPredicate(format: "%K == %@", key, value)
        return try get(type, predicate: predicate)
    }
}
