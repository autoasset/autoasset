//
//  Asset.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

fileprivate extension String {
    func camelCased() -> String {
        return self
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
            .split(separator: "_")
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
}

class Asset {
    
    let config: Config.Asset
    let xcassets: Xcassets

    class SplitImageResult {
        var imageFilePaths: [String: [FilePath]] = [:]
        var pdfsFilePaths: [FilePath] = []
        var gifFilePaths: [FilePath] = []
    }
    
    enum Placeholder {
        static let images = "[images_code]"
        static let gifs   = "[gifs_code]"
        static let datas  = "[datas_code]"
        static let colors = "[colors_code]"
        static let fonts  = "[fonts_code]"
    }
    
    var imageCode: [String] = []
    var gifCode:   [String] = []
    var dataCode:  [String] = []
    var colorCode: [String] = []
    var fontCode:  [String] = []

    static func start(config: Config.Asset) throws {
        let asset = try Asset(config: config)
        try asset.makeImages()
        try asset.output()
    }
    
    init(config: Config.Asset) throws {
        self.config = config
        self.xcassets = try Xcassets(config: config.xcassets)
    }
    
    func output() throws {
        guard let output = config.outputPath else {
            throw RunError(message: "Config: asset/output_path 不能为空")
        }
        
        var template = ""
        
        if let path = config.templatePath?.path {
            template = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            template = createTemplate()
        }
    
        try template
            .replacingOccurrences(of: Placeholder.images, with: imageCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.gifs, with: gifCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.datas, with: dataCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.colors, with: colorCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.fonts, with: fontCode.sorted().joined(separator: "\n"))
            .data(using: .utf8)?
            .write(to: output, options: [.atomicWrite])
    }
    
    
    
}

// MARK: - add
extension Asset {

    func variableName(with name: String) -> String {
        var caseName = name.camelCased()
        if name.first?.isNumber ?? false {
            caseName = "_\(caseName)"
            Warn.caseFirstCharIsNumber(caseName: name)
        }
        return caseName
    }
    
    func addGIFCode(with name: String) {
        gifCode.append("    static var \(variableName(with: name)): AssetSource.Data { AssetSource.Data(asset: \"\(name)\") }")
    }
    
    func addImageCode(with name: String) {
        imageCode.append("    static var \(variableName(with: name)): AssetSource.Image { AssetSource.Image(asset: \"\(name)\") }")
    }
    
}

extension Asset {

    func readImageFilePaths(folders: [FilePath]) throws -> [FilePath] {
        return folders.reduce([FilePath]()) { (result, item) -> [FilePath] in
            do {
                let files = try item.allSubFilePaths()
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
        let splitImageResult = try splitImageFilePaths(filePaths)
        if let path = config.xcassets.output.imagesXcassetsPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            try filePath.delete()
            try filePath.create()
            try makeImageAsset(splitImageResult.imageFilePaths, filePath)
            try makePDFDataAsset(splitImageResult.pdfsFilePaths, filePath)
        }
        if let path = config.xcassets.output.gifsXcassetsPath?.path {
            let filePath = try FilePath(path: path, type: .folder)
            try filePath.delete()
            try filePath.create()
            try makeGIFDataAsset(splitImageResult.gifFilePaths, filePath)
        }
    }

    /// 分离 image 与 gif 文件
    func splitImageFilePaths(_ filePaths: [FilePath]) throws -> SplitImageResult {
        let result = SplitImageResult()
        for item in filePaths {
            switch try item.data().st.mimeType {
            case .gif:
                result.gifFilePaths.append(item)
            case .pdf:
                result.pdfsFilePaths.append(item)
            default:
                guard let name = xcassets.createSourceNameKey(with: item.attributes.name) else {
                    continue
                }
                if result.imageFilePaths[name] == nil {
                    result.imageFilePaths[name] = [item]
                } else {
                    result.imageFilePaths[name]?.append(item)
                }
            }
        }
        return result
    }

    func makePDFDataAsset(_ filePaths: [FilePath], _ outputFilePath: FilePath) throws {
        let keySet = Set(filePaths.compactMap({ xcassets.createSourceNameKey(with: $0.attributes.name) }))
        try keySet.forEach { key in
            let folderName = key.replacingOccurrences(of: "@2x.", with: ".")
                .replacingOccurrences(of: "@3x.", with: ".")
            let folder = try outputFilePath.create(folder: "\(folderName).imageset")
            if let filePath = filePaths.first(where: { $0.attributes.name.hasPrefix("\(key).") || $0.attributes.name.hasPrefix("\(key)@") }) {
                try filePath.copy(to: folder)
                addImageCode(with: key)
                try xcassets.createPDFContents(with: [filePath.attributes.name]).write(to: folder.url.appendingPathComponent("Contents.json"), options: [.atomicWrite])
            }
        }
    }

    func makeGIFDataAsset(_ filePaths: [FilePath], _ outputFilePath: FilePath) throws {
        let keySet = Set(filePaths.compactMap({ xcassets.createSourceNameKey(with: $0.attributes.name) }))
        try keySet.forEach { key in
            let folderName = key.replacingOccurrences(of: "@2x.", with: ".")
                .replacingOccurrences(of: "@3x.", with: ".")
            let folder = try outputFilePath.create(folder: "\(folderName).dataset")
            if let filePath = filePaths.first(where: { $0.attributes.name.hasPrefix("\(key).") || $0.attributes.name.hasPrefix("\(key)@") }) {
                try filePath.copy(to: folder)
                addGIFCode(with: folderName)
                try xcassets.createDataContents(with: [filePath.attributes.name]).write(to: folder.url.appendingPathComponent("Contents.json"), options: [.atomicWrite])
            }
        }
    }

    func makeImageAsset(_ filePathMap: [String : [FilePath]], _ outputFilePath: FilePath) throws {
        let imageFolders = try filePathMap.map { key, value -> FilePath in
            let folder = try outputFilePath.create(folder: "\(key).imageset")
            addImageCode(with: key)
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
            let fileNames = try folder.subFilePaths().map({ $0.attributes.name })
            try xcassets.createImageContents(with: fileNames).write(to: folder.url.appendingPathComponent("Contents.json"), options: [.atomicWrite])
        }
    }

}


private extension Asset {
    
    func createTemplate() -> String {
        return """
        #if os(iOS) || os(tvOS) || os(watchOS)
        import UIKit
        #elseif os(OSX)
        import AppKit
        #endif

        import Foundation

        fileprivate class RBundle {
            static let bundle = Bundle(path: Bundle(for: RBundle.self).resourcePath!.appending("/Resources.bundle"))!
        }

        public enum R {
            public static let images = Image.self
            public static let gifs   = GIF.self
            static let colors = Color.self
            static let datas  = Data.self

            public enum Image { }
            public enum GIF { }
            enum Color { }
            enum Data { }
        }

        public class AssetSource {

            public class Base {
                public let name: String
                init(asset named: String) {
                    self.name = named
                }
            }

            public class Data: Base {
                public var data: Foundation.Data { NSDataAsset(name: name)!.data }
            }

            public class Image: Base {
                public var image: UIImage { UIImage(named: name, in: RBundle.bundle, compatibleWith: nil)! }
            }

        }

        public extension R.Image {
        [images_code]
        }

        public extension R.GIF {
        [gifs_code]
        }

        extension R.Color {
        [colors_code]
        }

        extension R.Data {
        [datas_code]
        }
        """
    }
    
}
