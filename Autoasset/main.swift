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

var warns = [Warn]()

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

struct Autoasset: ParsableCommand {
    static let configuration = CommandConfiguration(version: "1.0.0")

    @Option(name: [.short, .customLong("config")], help: "配置")
    var config: String

    func readImageFilePaths(folders: [FilePath]) throws -> [FilePath] {
        return folders.reduce([FilePath]()) { (result, item) -> [FilePath] in
            do {
                return result + (try item.subAllFilePaths()).filter({ $0.type == .file })
            } catch {
                return result
            }
        }
    }

    func run() throws {
        let config = try Config(url: URL(fileURLWithPath: self.config))
        try start(config: config)

    }

    func autoassetVersion() throws {
        print(Bundle.version())
    }

    func start(config: Config) throws {

        func makeImages() throws {
            var imageFolderPaths = [FilePath]()
            if let url = config.xcassets.input.imagesPath {
                let filePath = try FilePath(url: URL(fileURLWithPath: url.path), type: .folder)
                imageFolderPaths.append(filePath)
            }
            if let url = config.xcassets.input.gifsPath {
                let filePath = try FilePath(url: URL(fileURLWithPath: url.path), type: .folder)
                imageFolderPaths.append(filePath)
            }
            let filePaths = try readImageFilePaths(folders: imageFolderPaths)

            let (imageFilePaths, gifFilePaths) = try splitImageFilePaths(filePaths)

            if let url = config.xcassets.output.imagesXcassetsPath {
                let filePath = try FilePath(url: URL(fileURLWithPath: url.path), type: .folder)
                try filePath.delete()
                try filePath.create()
                try makeImageAsset(imageFilePaths, filePath)
            }

            if let url = config.xcassets.output.gifsXcassetsPath {
                let filePath = try FilePath(url: URL(fileURLWithPath: url.path), type: .folder)
                try filePath.delete()
                try filePath.create()
                try makeGIFDataAsset(gifFilePaths, filePath)
            }
        }

        try makeImages()

        if let url = config.asset.path {
            try Asset.shared.createTemplate(to: url)
        }
    }

}

extension Autoasset {

    private func splitImageFilePaths(_ filePaths: [FilePath]) throws -> (imageFilePaths: [String: [FilePath]],  gifFilePaths: [FilePath]) {
        var imageFilePaths = [String: [FilePath]]()
        var gifFilePaths = [FilePath]()
        for item in filePaths {
            guard item.fileName.hasPrefix(".") == false else {
                continue
            }
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

    private func makeGIFDataAsset(_ filePaths: [FilePath], _ outputFilePath: FilePath) throws {
        let keySet = Set(filePaths.compactMap({ Xcassets.shared.createSourceNameKey(with: $0.fileName) }))
        try keySet.forEach { key in
            let folderName = key.replacingOccurrences(of: "@2x.", with: ".")
                .replacingOccurrences(of: "@3x.", with: ".")
            let folder = try outputFilePath.create(folder: "\(folderName).dataset")
            if let filePath = filePaths.first(where: { $0.fileName.hasPrefix("\(key).") || $0.fileName.hasPrefix("\(key)@") }) {
                try filePath.move(to: folder)
                if let warn = Asset.shared.addGIFCode(with: folderName) {
                    warns.append(Warn(warn.message + "\npath: " + filePath.url.path))
                }
                try Xcassets.shared.createDataContents(with: [filePath.fileName]).write(to: folder.url.appendingPathComponent("Contents.json"))
            }
        }
    }

    private func makeImageAsset(_ filePathMap: [String : [FilePath]], _ outputFilePath: FilePath) throws {
        let imageFolders = try filePathMap.map { key, value -> FilePath in
            let folder = try outputFilePath.create(folder: "\(key).imageset")
            if let warn = Asset.shared.addImageCode(with: key) {
                warns.append(Warn(warn.message + "\n" + value.map({ "path: \($0.url.path)" }).joined(separator: "\n")))
            }
            var flag = false
            value.forEach { item in
                do {
                    try item.move(to: folder)
                } catch {
                    flag = true
                }
                if flag {
                    warns.append(Warn("文件重复\n" + value.map({ "path: \($0.url)" }).joined(separator: "\n")))
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
//let asset = Autoasset()
//do {
//    try asset.start(config: Config(url: URL(fileURLWithPath: #"/Users/linhey/Library/Developer/Xcode/DerivedData/Autoasset-cesnvfxrvtssyacujwludbzpqzhs/Build/Products/autoasset.package"#)))
//} catch {
//     print(error.localizedDescription)
//}
