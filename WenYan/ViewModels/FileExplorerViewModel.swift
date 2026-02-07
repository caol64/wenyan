//
//  FileExplorerViewModel.swift
//  WenYan
//
//  Created by Assistant on 2025/02/07.
//

import Foundation
import AppKit

@MainActor
final class FileExplorerViewModel: ObservableObject {
    private let appState: AppState
    @Published var projectRoot: URL?
    @Published var fileTree: [FileNode] = []
    @Published var currentFile: URL?
    @Published var recentFiles: [URL] = []
    @Published var showFileExplorer: Bool = true
    
    private var folderBookmark: Data?
    
    init(appState: AppState) {
        self.appState = appState
        loadPersistedState()
    }
    
    func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.title = "选择文件夹"
        openPanel.prompt = "打开"
        
        openPanel.begin { [weak self] response in
            guard let self = self, response == .OK, let url = openPanel.url else { return }
            self.openFolder(url)
        }
    }
    
    func openFolder(_ url: URL) {
        let gotAccess = url.startAccessingSecurityScopedResource()
        guard gotAccess else {
            appState.appError = AppError.bizError(description: "无法访问文件夹")
            return
        }
        
        projectRoot = url
        
        do {
            let bookmark = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
            folderBookmark = bookmark
            UserDefaults.standard.set(bookmark, forKey: "folderBookmark")
        } catch {
            appState.appError = AppError.bizError(description: "保存文件夹权限失败: \(error.localizedDescription)")
        }
        
        loadFileTree()
        url.stopAccessingSecurityScopedResource()
    }
    
    func openFile(_ node: FileNode) {
        guard node.type == .markdown else { return }
        
        currentFile = node.path
        addToRecentFiles(node.path)
        
        let gotAccess = node.path.startAccessingSecurityScopedResource()
        guard gotAccess else {
            appState.appError = AppError.bizError(description: "无法访问文件")
            return
        }
        
        do {
            let content = try String(contentsOfFile: node.path.path, encoding: .utf8)
            
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenFileFromExplorer"),
                object: nil,
                userInfo: ["content": content, "url": node.path]
            )
        } catch {
            appState.appError = AppError.bizError(description: "读取文件失败: \(error.localizedDescription)")
        }
        
        node.path.stopAccessingSecurityScopedResource()
    }
    
    func toggleExpand(_ node: FileNode) {
        guard node.type == .folder else { return }
        
        node.isExpanded.toggle()
        
        if node.isExpanded && node.children == nil {
            loadChildren(for: node)
        }
    }
    
    func toggleFileExplorer() {
        showFileExplorer.toggle()
        appState.showFileExplorer = showFileExplorer
        UserDefaults.standard.set(showFileExplorer, forKey: "showFileExplorer")
    }
    
    private func loadFileTree() {
        guard let rootURL = projectRoot else { return }
        
        let gotAccess = rootURL.startAccessingSecurityScopedResource()
        defer { rootURL.stopAccessingSecurityScopedResource() }
        
        guard gotAccess else { return }
        
        fileTree = buildFileTree(from: rootURL)
    }
    
    private func buildFileTree(from url: URL, depth: Int = 0) -> [FileNode] {
        let maxDepth = 5
        guard depth < maxDepth else { return [] }
        
        let fileManager = FileManager.default
        let contents: [URL]
        
        do {
            contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
        } catch {
            appState.appError = AppError.bizError(description: "加载文件树失败: \(error.localizedDescription)")
            return []
        }
        
        var nodes: [FileNode] = []
        
        for item in contents {
            let resourceValues: URLResourceValues
            do {
                resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
            } catch {
                continue
            }
            
            let isDirectory = resourceValues.isDirectory ?? false
            
            if isDirectory {
                let node = FileNode(name: item.lastPathComponent, path: item, type: .folder)
                nodes.append(node)
            } else {
                let fileType = getFileType(for: item)
                if fileType == .markdown || fileType == .image || fileType == .other {
                    let node = FileNode(name: item.lastPathComponent, path: item, type: fileType)
                    nodes.append(node)
                }
            }
        }
        
        nodes.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        return nodes
    }
    
    private func loadChildren(for node: FileNode) {
        guard node.type == .folder else { return }
        
        let gotAccess = node.path.startAccessingSecurityScopedResource()
        defer { node.path.stopAccessingSecurityScopedResource() }
        
        guard gotAccess else { return }
        
        node.children = buildFileTree(from: node.path)
    }
    
    private func getFileType(for url: URL) -> FileType {
        let pathExtension = url.pathExtension.lowercased()
        
        if pathExtension == "md" || pathExtension == "markdown" {
            return .markdown
        } else if ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp", "ico"].contains(pathExtension) {
            return .image
        } else {
            return .other
        }
    }
    
    private func addToRecentFiles(_ url: URL) {
        recentFiles.removeAll { $0 == url }
        recentFiles.insert(url, at: 0)
        if recentFiles.count > 10 {
            recentFiles = Array(recentFiles.prefix(10))
        }
        
        let urls = recentFiles.compactMap { try? $0.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil) }
        UserDefaults.standard.set(urls, forKey: "recentFiles")
    }
    
    private func loadPersistedState() {
        let persistedShowFileExplorer = UserDefaults.standard.bool(forKey: "showFileExplorer")
        showFileExplorer = persistedShowFileExplorer
        appState.showFileExplorer = persistedShowFileExplorer
        
        if let bookmarkData = UserDefaults.standard.data(forKey: "folderBookmark") {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope, .withoutUI], relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if isStale {
                    let newBookmark = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
                    folderBookmark = newBookmark
                    UserDefaults.standard.set(newBookmark, forKey: "folderBookmark")
                }
                
                openFolder(url)
            } catch {
                print("Failed to restore folder from bookmark: \(error)")
            }
        }
        
        if let recentFilesData = UserDefaults.standard.array(forKey: "recentFiles") as? [Data] {
            var urls: [URL] = []
            for bookmarkData in recentFilesData {
                var isStale = false
                do {
                    let url = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope, .withoutUI], relativeTo: nil, bookmarkDataIsStale: &isStale)
                    urls.append(url)
                } catch {
                    continue
                }
            }
            recentFiles = urls
        }
    }
}
