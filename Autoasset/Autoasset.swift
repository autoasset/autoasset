//
//  Autoasset.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/7.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

class Autoasset {

    static let version = "1"
    static var isDebug = false

    let config: Config
    lazy var asset = Asset(config: config.asset)

    init(config: Config) {
        Autoasset.isDebug = config.debug
        self.config = config
    }

    func start() throws {
        let podspec = Podspec(config: config.podspec)
        let git = Git(config: config.git)
        try? git.fetch()
        try? git.pull()

        try makeImages()
        try asset.output()

        if let warn = config.warn {
            try Warn.output(config: warn)
        }

        try podspec?.lint()
        
        let isChanged = try git.diff().isEmpty == false
        let nextVersion = try git.tag.nextVersion()
        if nextVersion != nil, isChanged == false {
            return
        }

        guard let version = nextVersion else {
            return
        }

        try podspec?.output(version: version)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD HH:MM:SS"

        let message = "tag: \(version), author: autoasset(\(Autoasset.version)), date: \(dateFormatter.string(from: Date()))"
        if isChanged {
            try git.addAllFile()
            try git.commit(message: message)
            try? git.pull()
            try? git.push(version: version)
        }
        try? git.tag.remove(version: version)
        try? git.tag.add(version: version, message: message)
        try? git.tag.push(version: version)
        try podspec?.push()
    }

}

private
extension Autoasset {

    func readImageFilePaths(folders: [FilePath]) throws -> [FilePath] {
        return folders.reduce([FilePath]()) { (result, item) -> [FilePath] in
            do {
                let files = try item.subAllFilePaths()
                return result + files.filter({ $0.type == .file })
            } catch {
                return result
            }
        }
    }

    func makeImages() throws {
        var imageFolderPaths = [FilePath]()
        if let path = config.xcassets.input.imagesPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            imageFolderPaths.append(filePath)
        }
        if let path = config.xcassets.input.gifsPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            imageFolderPaths.append(filePath)
        }
        let filePaths = try readImageFilePaths(folders: imageFolderPaths)
        let (imageFilePaths, gifFilePaths) = try splitImageFilePaths(filePaths)
        if let path = config.xcassets.output.imagesXcassetsPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            try filePath.delete()
            try filePath.create()
            try makeImageAsset(imageFilePaths, filePath, asset: &asset)
        }
        if let path = config.xcassets.output.gifsXcassetsPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            try filePath.delete()
            try filePath.create()
            try makeGIFDataAsset(gifFilePaths, filePath, asset: &asset)
        }
    }

    /// 分离 image 与 gif 文件
    func splitImageFilePaths(_ filePaths: [FilePath]) throws -> (imageFilePaths: [String: [FilePath]],  gifFilePaths: [FilePath]) {
        var imageFilePaths = [String: [FilePath]]()
        var gifFilePaths = [FilePath]()
        for item in filePaths {
            switch try item.data().st.mimeType {
            case .gif:
                gifFilePaths.append(item)
            default:
                guard let name = Xcassets.shared.createSourceNameKey(with: item.fileName) else {
                    continue
                }
                if imageFilePaths[name] == nil {
                    imageFilePaths[name] = [item]
                } else {
                    imageFilePaths[name]?.append(item)
                }
            }
        }
        return (imageFilePaths, gifFilePaths)
    }

    func makeGIFDataAsset(_ filePaths: [FilePath], _ outputFilePath: FilePath, asset: inout Asset) throws {
        let keySet = Set(filePaths.compactMap({ Xcassets.shared.createSourceNameKey(with: $0.fileName) }))
        try keySet.forEach { key in
            let folderName = key.replacingOccurrences(of: "@2x.", with: ".")
                .replacingOccurrences(of: "@3x.", with: ".")
            let folder = try outputFilePath.create(folder: "\(folderName).dataset")
            if let filePath = filePaths.first(where: { $0.fileName.hasPrefix("\(key).") || $0.fileName.hasPrefix("\(key)@") }) {
                try filePath.copy(to: folder)
                asset.addGIFCode(with: folderName)
                try Xcassets.shared.createDataContents(with: [filePath.fileName]).write(to: folder.url.appendingPathComponent("Contents.json"), options: [.atomicWrite])
            }
        }
    }

    func makeImageAsset(_ filePathMap: [String : [FilePath]], _ outputFilePath: FilePath, asset: inout Asset) throws {
        let imageFolders = try filePathMap.map { key, value -> FilePath in
            let folder = try outputFilePath.create(folder: "\(key).imageset")
            asset.addImageCode(with: key)
            value.forEach { item in
                do {
                    try item.copy(to: folder)
                } catch {
                    Warn((error as? FilePath.FilePathError)?.message ?? "")
                }
            }
            return folder
        }

        try imageFolders.forEach { folder in
            let fileNames = try folder.subFilePaths().map({ $0.fileName })
            try Xcassets.shared.createImageContents(with: fileNames).write(to: folder.url.appendingPathComponent("Contents.json"), options: [.atomicWrite])
        }
    }

}
