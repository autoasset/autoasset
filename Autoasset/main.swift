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
    static let configuration = CommandConfiguration(abstract: "Word counter.")

    @Option(name: [.short, .customLong("input")], help: "输入: 资源文件夹路径")
    var input: String

    @Option(name: [.short, .customLong("xcassets")], default: "./image.xcassets", help: "输出: xcassets路径")
    var xcassets: String

    @Option(name: [.short, .customLong("asset")], default: "./asset.swift", help: "输出: asset文件路径")
    var asset: String

    @Option(name: [.customLong("warn")], default: nil, help: "输出: warn文件路径")
    var warn: String?

    @Option(name: [.customLong("isUseInLibrary")], default: false, help: "是否用于静态库输出")
    var isUseInLibrary: Bool

    @Option(name: [.customLong("bundleName")], default: "Asset", help: "静态库内 bundle 名")
    var bundleName: String

    func run() throws {
        let inputFilePath  = try FilePath(url: URL(fileURLWithPath: input))
        let tempFilePath   = try FilePath(url: URL(fileURLWithPath: "./tempAutoasset"), type: .folder)
        let outputFilePath = try FilePath(url: URL(fileURLWithPath: xcassets), type: .folder)
        let assetFilePath  = try FilePath(url: URL(fileURLWithPath: asset), type: .file)

        guard inputFilePath.type == .folder else {
            throw RuntimeError("inputFile 不能是文件, 只能是文件夹")
        }

        Asset.shared.bundleName = bundleName
        Asset.shared.isUseInLibrary = isUseInLibrary

        try tempFilePath.delete()
        try inputFilePath.copy(to: tempFilePath)
        let filePaths = try tempFilePath.subAllFilePaths().filter({ $0.type == .file })

        let (imageFilePaths, gifFilePaths) = try splitImageFilePaths(filePaths)
        try outputFilePath.delete()
        try outputFilePath.create()
        try makeImageAsset(imageFilePaths, outputFilePath)
        try makeGIFDataAsset(gifFilePaths, outputFilePath)
        try Asset.shared.createTemplate().data(using: .utf8)?.write(to: assetFilePath.url)
        let warnFile = warns.map({ $0.message }).joined(separator: "\n")
        print(warnFile)
        if let warn = warn {
            try warnFile.data(using: .utf8)?.write(to: URL(fileURLWithPath: warn))
        }

        if isUseInLibrary {
            let code = """
            在podspec中添加以下代码
            s.resource_bundles = {
                'Assets' => ['Sources/Assets/*.xcassets']
            }

            在podfile中移除 use_framework! 字段
            """
            print(code)
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
                    warns.append(Warn("文件重复\n" + value.map({ "path: \($0.url.path)" }).joined(separator: "\n")))
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
//var count = Autoasset()
//count.input    = "./UI/"
//count.xcassets = "./image.xcassets"
//count.asset    = "./asset.swift"
//count.warn     = "./warn.txt"
//count.bundleName = "Asset"
//count.isUseInLibrary = false
//try! count.run()
