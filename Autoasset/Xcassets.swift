//
//  Xcassets.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/26.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//
import Foundation
import Stem

class Xcassets {

    enum ResourceType {
        case image
        case data
        case color
    }

    let type: ResourceType
    let config: AssetModel.Xcasset
    var contents: [String: FilePath] = [:]

    init(config: AssetModel.Xcasset, use type: ResourceType) throws {
        self.config = config
        self.type = type
        self.contents = try read(from: config.contents, predicate: { $0.attributes.name.hasSuffix(".json") })
            .reduce([String: FilePath](), { (result, file) -> [String: FilePath] in
                var result = result
                if let name = file.attributes.name.split(separator: ".").first?.description {
                    result[name] = file
                }
                return result
            })
    }

    static func deleteOutput(folders: [AssetModel.Xcasset]) {
        folders.forEach({ try? FilePath(url: $0.output, type: .folder).delete() })
    }

    func run() throws -> [String] {
        switch type {
        case .image:
            return try runImage()
        case .data:
            return try runData()
        case .color:
            // try runColor()
            break
        }

        return []
    }

}

extension Xcassets {

    func read(from inputs: AssetModel.Inputs, predicate: ((FilePath) throws -> Bool)? = nil) throws -> [FilePath] {
        return try inputs.inputs.compactMap({ try FilePath(url: $0, type: .folder) }).reduce([FilePath](), { (result, file) -> [FilePath] in
            try file.allSubFilePaths(predicate: predicate)
        })
    }


    func group(from filePaths: [FilePath], namePredicate: (FilePath) throws -> String) throws -> [String: [FilePath]] {
        var groups = [String: [FilePath]]()

        for file in filePaths {
            let name = try namePredicate(file)
            if groups[name] != nil {
                groups[name]?.append(file)
            } else {
                groups[name] = [file]
            }
        }

        return groups
    }

    func removeDuplicate(in group: [FilePath]) -> [FilePath] {
        var dict = [String: [FilePath]]()

        for file in group {
            let name = file.attributes.name.split(separator: ".").first?.description ?? file.attributes.name
            if dict[name] == nil {
                dict[name] = [file]
            } else {
                dict[name]?.append(file)
            }
        }

        return dict.compactMap { _, files -> FilePath? in
            if files.count > 1 {
                Warn.duplicateFiles(files)
            }
            return files.first
        }
    }

}

// MARK: - image
extension Xcassets {

    struct Appearances {
        enum ValueType: String {
            case light
            case dark
        }

        let appearance = "luminosity"
        let value: ValueType

        var dict: [String: Any]? {
            return ["value": value.rawValue,
                    "appearance": appearance]
        }

    }

    struct ImageItem {

        enum SourceType {
            case image
            case vector
        }

        let name: String
        let type: SourceType

        init(name: String, type: SourceType) {
            self.name = name
            self.type = type
        }

        var dict: [String: Any] {
            var dict = [String: Any]()

            if name.contains("_dark@") || name.contains("_dark.") || name.hasSuffix("_dark") {
                let appearances = Appearances(value: .dark)
                dict["appearances"] = appearances.dict
            }

            if name.contains("_light@") || name.contains("_light.") || name.hasSuffix("_light") {
                let appearances = Appearances(value: .light)
                dict["appearances"] = appearances.dict
            }

            dict["idiom"] = "universal"
            dict["filename"] = name

            switch type {
            case .vector:
                break
            case .image:
                if name.contains("@1x") {
                    dict["scale"] = "1x"
                } else if name.contains("@2x") {
                    dict["scale"] = "2x"
                } else if name.contains("@3x") {
                    dict["scale"] = "3x"
                } else {
                    dict["scale"] = "2x"
                }
            }

            return dict
        }
    }

    func runImage() throws -> [String] {
        let types: [Data.MimeType] = [.png, .jpeg, .pdf]
        let sources = try read(from: config, predicate: { try types.contains($0.data().st.mimeType) })
        let groups = try group(from: sources, namePredicate: { file -> String in
            return file.attributes.name
                .components(separatedBy: "_dark@").first?
                .split(separator: "@").first?
                .split(separator: ".").first?.description ?? file.attributes.name
        })
        return try groups.compactMap { (name, files) -> String? in
            return try createImageXcasset(name: name, files: files)
        }
    }

    func createImageXcasset(name: String, files: [FilePath]) throws -> String? {
        guard files.isEmpty == false else {
            return nil
        }
        let files = removeDuplicate(in: files)

        let folder = try FilePath(url: config.output, type: .folder)
        let imageset = try folder.create(folder: "\(name).imageset")

        for file in files {
            do {
                try file.copy(to: imageset)
            } catch {
                Warn((error as? FilePath.Error)?.message ?? "")
            }
        }

        let contents = try createImageContents(name: name, files: files)
        try imageset.create(file: "Contents.json", data: contents)

        return name
    }

    func createImageContents(name: String, files: [FilePath]) throws -> Data {
        if let file = contents[name] { return try file.data() }
        let pdfFiles = try files.filter { file -> Bool in
            return try file.data().st.mimeType == .pdf
        }

        if pdfFiles.isEmpty == false {
            let info: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
            let properties: [String: Any] = ["compression-type": "automatic", "preserves-vector-representation": true]
            let images = files.map{( ImageItem(name: $0.attributes.name, type: .image).dict )}
            let contents: [String: Any] = ["info": info, "properties": properties, "images": images]
            return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        }

        let imageFiles = try files.filter { file -> Bool in
            return [.jpeg, .png].contains(try file.data().st.mimeType)
        }

        if imageFiles.isEmpty == false {
            let info: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
            let images = files.map{( ImageItem(name: $0.attributes.name, type: .image).dict )}
            let contents = ["info": info, "images": images] as [String : Any]
            return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        }

        throw RunError(message: "xcassets: 文件格式匹配错误 现支持 png | jpg | pdf, \n path:\(config.inputs)")
    }

}

extension Xcassets {

    func runData() throws -> [String] {
        let types: [Data.MimeType] = [.png, .jpeg, .pdf]
        let sources = try read(from: config, predicate: { try types.contains($0.data().st.mimeType) == false })
        let groups = try group(from: sources, namePredicate: { file -> String in
            return file.attributes.name
                .split(separator: "@").first?
                .split(separator: ".").first?.description ?? file.attributes.name
        })
        return try groups.compactMap { (name, files) -> String? in
            if files.count > 1 {
                Warn.duplicateFiles(files)
            }
            return try createDataXcasset(name: name, file: files[0])
        }
    }

    func createDataXcasset(name: String, file: FilePath) throws -> String? {
        let folder = try FilePath(url: config.output, type: .folder)
        let imageset = try folder.create(folder: "\(name).dataset")
        try file.copy(to: imageset)
        let contents = try createDataContents(name: name, file: file)
        try imageset.create(file: "Contents.json", data: contents)
        return name
    }

    func createDataContents(name: String, file: FilePath) throws -> Data {
        if let file = contents[name] { return try file.data() }
        var contents: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
        contents["data"] = [["idiom": "universal", "filename": file.attributes.name]]
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }

}

