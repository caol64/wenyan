//
//  FileNode.swift
//  WenYan
//
//  Created by Assistant on 2025/02/07.
//

import Foundation

enum FileType: Equatable {
    case folder
    case markdown
    case image
    case other
    
    var isFolder: Bool {
        self == .folder
    }
    
    var isMarkdown: Bool {
        self == .markdown
    }
    
    var isImage: Bool {
        self == .image
    }
}

@MainActor
class FileNode: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    let path: URL
    let type: FileType
    @Published var isExpanded: Bool
    @Published var isSelected: Bool
    @Published var children: [FileNode]?
    
    init(name: String, path: URL, type: FileType, isExpanded: Bool = false, isSelected: Bool = false, children: [FileNode]? = nil) {
        self.name = name
        self.path = path
        self.type = type
        self.isExpanded = isExpanded
        self.isSelected = isSelected
        self.children = children
    }
    
    convenience init(url: URL, type: FileType) {
        self.init(name: url.lastPathComponent, path: url, type: type)
    }
}
