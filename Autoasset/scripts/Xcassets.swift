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

    func read(from inputs: Inputs, predicate: ((FilePath) throws -> Bool)? = nil) throws -> [FilePath] {
        return try inputs.inputs.compactMap({ try FilePath(url: $0, type: .folder) }).reduce([FilePath](), { (result, file) -> [FilePath] in
            var result = result
            if let predicate = predicate {
                result.append(contentsOf: try file.allSubFilePaths(predicates: [.skipsHiddenFiles,
                                                                                .custom({ $0.type == .file }),
                                                                                .custom(predicate)]))
            } else {
                result.append(contentsOf: try file.allSubFilePaths(predicates: [.skipsHiddenFiles,
                                                                                .custom({ $0.type == .file })]))
            }
            return result
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
                Warn.duplicateFiles(baseURL: self.config.base, files)
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
            case any
        }

        let appearance = "luminosity"
        var value: ValueType

        var dict: [String: Any]? {
            switch value {
            case .any:
                return nil
            default:
                return  ["value": value.rawValue, "appearance": appearance]
            }
        }

    }

    struct ImageItem {

        let items: [ImageItemElemnt]

        init(elements: [ImageItemElemnt]) {
            var items: [ImageItemElemnt] = []

            func isAnyStyle(_ element: ImageItemElemnt) -> Bool {
                if let appearances = element.appearances {
                    return appearances.value == .any || appearances.value == .light
                } else {
                    return true
                }
            }

            if elements.contains(where: { $0.appearances?.value == .dark }) {
                ImageItemElemnt.Scale.allCases.forEach { scale in
                    let any = elements.first(where: { $0.scale == scale && isAnyStyle($0) })
                        ?? ImageItemElemnt(type: .image, scale: scale, appearances: .init(value: .any))
                    let dark = elements.first(where: { $0.scale == scale && $0.appearances?.value == .dark })
                    let darkPlaceholder = ImageItemElemnt(type: .image, scale: scale, appearances: .init(value: .dark))
                    items.append(contentsOf: [any, dark ?? darkPlaceholder])
                }
            } else {
               items = ImageItemElemnt.Scale.allCases.map { scale -> ImageItemElemnt in
                var element = elements.first(where: { $0.scale == scale && isAnyStyle($0) })

                if element == nil {
                   element = ImageItemElemnt(type: .image, scale: scale, appearances: .init(value: .any))
                }

                element!.appearances?.value = .any
                return element!
                }
            }
            self.items = items
        }

        var output: [Any] {
            return items.map({ $0.dict })
        }
    }

    struct ImageItemElemnt {

        enum SourceType {
            case image
            case vector
        }

        enum Scale: String, CaseIterable {
            case x1 = "@1x"
            case x2 = "@2x"
            case x3 = "@3x"

            func output() -> String {
                switch self {
                case .x1: return "1x"
                case .x2: return "2x"
                case .x3: return "3x"
                }
            }
        }

        let name: String?
        let type: SourceType
        let scale: Scale
        var appearances: Appearances?

        init(type: SourceType, scale: Scale, appearances: Appearances?) {
            self.name = nil
            self.type = type
            self.scale = scale
            self.appearances = appearances
        }

        init(name: String, type: SourceType) {
            self.name = name
            self.type = type

            if name.contains(Scale.x1.rawValue) {self.scale = .x1 }
            else if name.contains(Scale.x2.rawValue) { self.scale = .x2 }
            else if name.contains(Scale.x3.rawValue) { self.scale = .x3 }
            else { self.scale = .x2 }

            if name.contains("_dark@") || name.contains("_dark.") || name.hasSuffix("_dark") {
                appearances = Appearances(value: .dark)
            } else {
                appearances = nil
            }

        }

        var dict: [String: Any] {
            var dict = [String: Any]()

            dict["appearances"] = appearances?.dict
            dict["idiom"] = "universal"
            dict["filename"] = name

            switch type {
            case .vector:
                break
            case .image:
                dict["scale"] = scale.output()
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
            let info: [String: Any] = ["version": 1, "author": "xcode"]
            let properties: [String: Any] = ["compression-type": "automatic", "preserves-vector-representation": true]
            let images = files.map{( ImageItemElemnt(name: $0.attributes.name, type: .image).dict )}
            let contents: [String: Any] = ["info": info, "properties": properties, "images": images]
            return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        }

        let imageFiles = try files.filter { file -> Bool in
            return [.jpeg, .png].contains(try file.data().st.mimeType)
        }

        if imageFiles.isEmpty == false {
            let info: [String: Any] = ["version": 1, "author": "xcode"]
            let imageItemElemnts = files.map{( ImageItemElemnt(name: $0.attributes.name, type: .image) )}

            let contents = ["info": info, "images": ImageItem(elements: imageItemElemnts).output] as [String : Any]
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
                Warn.duplicateFiles(baseURL: self.config.base, files)
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

