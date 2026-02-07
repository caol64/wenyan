//
//  FileExplorerView.swift
//  WenYan
//
//  Created by Assistant on 2025/02/07.
//

import SwiftUI

struct FileExplorerView: View {
    @ObservedObject var viewModel: FileExplorerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            if viewModel.projectRoot == nil {
                emptyState
            } else {
                fileTreeList
            }
        }
        .frame(minWidth: 200, maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var header: some View {
        HStack {
            if let root = viewModel.projectRoot {
                Text(root.lastPathComponent)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .help(root.path)
            } else {
                Text("文件资源管理器")
                    .font(.system(size: 13, weight: .medium))
            }
            
            Spacer()
            
            Button(action: viewModel.toggleFileExplorer) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .help("隐藏/显示侧边栏")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("未打开文件夹")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Button("打开文件夹") {
                viewModel.selectFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var fileTreeList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModel.fileTree) { node in
                    FileNodeRow(node: node, viewModel: viewModel, depth: 0)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct FileNodeRow: View {
    @ObservedObject var node: FileNode
    @ObservedObject var viewModel: FileExplorerViewModel
    let depth: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            rowContent
            
            if node.isExpanded, let children = node.children {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(children) { child in
                        FileNodeRow(node: child, viewModel: viewModel, depth: depth + 1)
                    }
                }
            }
        }
    }
    
    private var rowContent: some View {
        HStack(spacing: 4) {
            ForEach(0..<depth) { _ in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 16)
            }

            icon

            Text(node.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.tail)
                .help(Text(node.path.path))
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .help(Text(node.path.path))
        .onTapGesture {
            if node.type == .folder {
                viewModel.toggleExpand(node)
            } else if node.type == .markdown {
                viewModel.openFile(node)
            }
        }
        .background(node.isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        .cornerRadius(4)
    }
    
    private var icon: some View {
        Group {
            switch node.type {
            case .folder:
                Image(systemName: node.isExpanded ? "folder.fill" : "folder")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 14))
            case .markdown:
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            case .image:
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            case .other:
                Image(systemName: "doc")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
        }
        .onTapGesture {
            if node.type == .folder {
                viewModel.toggleExpand(node)
            }
        }
    }
}

#Preview {
    FileExplorerView(viewModel: FileExplorerViewModel(appState: AppState()))
}
