//
//  File.swift
//  AX
//
//  Created by 林翰 on 2020/2/16.
//  Copyright © 2020 linhey.ax. All rights reserved.
//

import Foundation

class FilePath: Equatable {

    static func == (lhs: FilePath, rhs: FilePath) -> Bool {
        return lhs.url == rhs.url && rhs.type == lhs.type
    }
    
    struct FilePathError: Error {
        let message: String
        let code: Int
    }
    
    enum `Type` {
        case folder
        case file
    }
    
    private let manager = FilePath.manager
    private static let manager = FileManager.default
    
    var url: URL
    var type: Type
    
    func data() throws -> Data {
        return try Data(contentsOf: url)
    }
    
    var fileName: String {
        return url.lastPathComponent
    }

    convenience init(path: String, type: Type? = nil) throws {
        guard let url = URLComponents(url: URL(fileURLWithPath: path), resolvingAgainstBaseURL: true)?.url else {
            throw FilePathError(message: "path解析错误: \(path)", code: 0)
        }
        try self.init(url: url, type: type)
    }
    
    init(url: URL, type: Type? = nil) throws {
        guard url.isFileURL else {
            throw FilePathError(message: "目标路径不是文件路径", code: -1)
        }
        self.url = url
        if let type = type {
            self.type = type
        } else {
            self.type = try FilePath.checkType(url: url)
        }
    }
    
    /// 创建文件夹
    func create() throws {
        guard isExist() == false else {
            throw FilePathError(message: "文件存在, 无法创建", code: -1)
        }
        
        switch type {
        case .file:
            manager.createFile(atPath: url.path, contents: nil, attributes: nil)
        case .folder:
            try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
    }
    
    func isExist() -> Bool {
        return manager.fileExists(atPath: url.path)
    }
    
    /// 创建文件夹
    @discardableResult
    func create(folder name: String) throws -> FilePath {
        let folder = url.appendingPathComponent(name, isDirectory: true)
        let exist = manager.fileExists(atPath: folder.path)
        
        guard exist == false else {
            return try FilePath(url: folder, type: .folder)
        }
        
        try manager.createDirectory(at: folder,
                                    withIntermediateDirectories: true,
                                    attributes: nil)
        return try FilePath(url: folder, type: .folder)
    }
    
}

extension FilePath {

    func move(to path: FilePath) throws {
        switch path.type {
        case .file:
            try manager.moveItem(at: url, to: path.url)
        case .folder:
            let fileURL = path.url.appendingPathComponent(fileName)
            try manager.moveItem(at: url, to: fileURL)
        }
    }
    
    func delete() throws {
        guard isExist() else {
            return
        }
        try manager.removeItem(at: url)
    }
    
    func copy(to path: FilePath) throws {
        if path.isExist() {
            try path.delete()
        }
        try manager.copyItem(at: url, to: path.url)
    }
    
}

// MARK: - get subFilePaths
extension FilePath {
    
    /// 递归获取文件夹中所有文件/文件夹
    func subAllFilePaths() throws -> [FilePath] {
        guard self.type == .folder else {
            throw FilePathError(message: "目标路径不是文件夹类型", code: -1)
        }
        guard let enumerator = manager.enumerator(atPath: url.path) else {
            return []
        }
        var list = [FilePath]()
        for case let path as String in enumerator {
            guard path.hasPrefix(".") else {
                continue
            }
            guard let fullPath = enumerator.value(forKey: "path") as? String else {
                continue
            }
            guard let item = try? FilePath(url: URL(fileURLWithPath: fullPath + path)) else {
                continue
            }
            list.append(item)
        }
        return list
    }
    
    /// 获取文件夹中文件/文件夹
    func subFilePaths() throws -> [FilePath] {
        guard self.type == .folder else {
            throw FilePathError(message: "目标路径不是文件夹类型", code: -1)
        }
        
        return try manager
            .contentsOfDirectory(at: url,
                                 includingPropertiesForKeys: nil,
                                 options: .skipsHiddenFiles)
            .compactMap({ try? FilePath(url: $0) })
    }
    
}

extension FilePath {
    
    /// 文件/文件夹类型
    static func checkType(url: URL) throws -> Type {
        var isDir : ObjCBool = false
        if manager.fileExists(atPath: url.path, isDirectory:&isDir) {
            if isDir.boolValue {
                return .folder
            } else {
                return .file
            }
        } else {
            throw FilePathError(message: "目标路径文件不存在: \(url.description)", code: -2)
        }
    }
    
}
