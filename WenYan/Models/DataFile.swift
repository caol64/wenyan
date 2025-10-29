//
//  DataFile.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/27.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DataFile: FileDocument {
    static var readableContentTypes: [UTType] { [.jpeg, .pdf] }
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
