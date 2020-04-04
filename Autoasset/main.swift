//
//  main.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//
import Foundation
import ArgumentParser
import Stem

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

struct Autoasset: ParsableCommand {
    static let configuration = CommandConfiguration(version: "1")

    @Option(name: [.short, .customLong("config")], help: "配置")
    var config: String

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

    func run() throws {
        let config = try Config(url: FilePath(path: self.config, type: .file).url)
        try start(config: config)
    }

    func start(config: Config) throws {
        var asset = Asset(config: config.asset)

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

        try makeImages()
        try asset.output()

        if let podspec = config.podspec {
            try Podspec(config: podspec).output()
        }

        if let warn = config.warn {
            try Warn.output(config: warn)
        }
    }

}

extension Autoasset {

    /// 分离 image 与 gif 文件
    private func splitImageFilePaths(_ filePaths: [FilePath]) throws -> (imageFilePaths: [String: [FilePath]],  gifFilePaths: [FilePath]) {
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

    private func makeGIFDataAsset(_ filePaths: [FilePath], _ outputFilePath: FilePath, asset: inout Asset) throws {
        let keySet = Set(filePaths.compactMap({ Xcassets.shared.createSourceNameKey(with: $0.fileName) }))
        try keySet.forEach { key in
            let folderName = key.replacingOccurrences(of: "@2x.", with: ".")
                .replacingOccurrences(of: "@3x.", with: ".")
            let folder = try outputFilePath.create(folder: "\(folderName).dataset")
            if let filePath = filePaths.first(where: { $0.fileName.hasPrefix("\(key).") || $0.fileName.hasPrefix("\(key)@") }) {
                try filePath.copy(to: folder)
                asset.addGIFCode(with: folderName)
                try Xcassets.shared.createDataContents(with: [filePath.fileName]).write(to: folder.url.appendingPathComponent("Contents.json"))
            }
        }
    }

    private func makeImageAsset(_ filePathMap: [String : [FilePath]], _ outputFilePath: FilePath, asset: inout Asset) throws {
        let imageFolders = try filePathMap.map { key, value -> FilePath in
            let folder = try outputFilePath.create(folder: "\(key).imageset")
            asset.addImageCode(with: key)
            value.forEach { item in
                do {
                    print(item.url)
                    try item.copy(to: folder)
                } catch {
                    Warn((error as? FilePath.FilePathError)?.message ?? "")
                }
            }
            return folder
        }

        try imageFolders.forEach { folder in
            let fileNames = try folder.subFilePaths().map({ $0.fileName })
            try Xcassets.shared.createImageContents(with: fileNames).write(to: folder.url.appendingPathComponent("Contents.json"))
        }
    }

}

Autoasset.main()
