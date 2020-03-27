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

    static var shared = Xcassets()

    func createSourceNameKey(with fileName: String) -> String? {
        return fileName.split(separator: "@").first?.split(separator: ".").first?.description
    }

    func createDataContents(with fileNames: [String]) throws -> Data {
        var contents: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
        contents["data"] = fileNames.map { ["idiom": "universal", "filename": $0] }
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted])
    }

    func createImageContents(with fileNames: [String]) throws -> Data {
        var contents: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
        var list = [[String: String]]()
        do {
            var dict = ["idiom": "universal", "scale": "3x"]
            if let name = fileNames.first(where: { $0.contains("@3x.") }) {
                dict["filename"] = name
            }
            list.append(dict)
        }
        do {
            var dict = ["idiom": "universal", "scale": "2x"]
            if let name = fileNames.first(where: { $0.contains("@2x.") }) {
                dict["filename"] = name
            }
            list.append(dict)
        }
        do {
            var dict = ["idiom": "universal", "scale": "1x"]
            if let name = fileNames.first(where: { $0.contains("@2x.") == false && $0.contains("@3x.") == false }) {
                dict["filename"] = name
            }
            list.append(dict)
        }
        contents["images"] = list
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted])
    }

}

extension String {
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

    static let shared = Asset()

    var imageCode: [String] = []
    var gifCode: [String]   = []
    var dataCode: [String]  = []
    var colorCode: [String] = []

    func addGIFCode(with name: String) -> Warn? {
        if name.first?.isNumber ?? false {
            let caseName = name.camelCased()
            gifCode.append("    static var _\(caseName): Data { NSDataAsset(name: \"\(name)\")!.data }")
            return Warn("首字母不能为数字: \(caseName), 已更替为 _\(caseName)")
        }else {
            gifCode.append("    static var \(name.camelCased()): Data { NSDataAsset(name: \"\(name)\")!.data }")
            return nil
        }
    }

    func addImageCode(with name: String) -> Warn? {
        if name.first?.isNumber ?? false {
            let caseName = name.camelCased()
            imageCode.append("    static var _\(caseName): AssetImage { AssetImage(named: \"\(name)\")! }")
            return Warn("首字母不能为数字: \(caseName), 已更替为 _\(caseName)")
        }else {
            imageCode.append("    static var \(name.camelCased()): AssetImage { AssetImage(named: \"\(name)\")! }")
            return nil
        }
    }

    func createTemplate() -> String {
        
        return """
        #if os(iOS) || os(tvOS) || os(watchOS)
        import UIKit
        public typealias AssetImage = UIImage
        #elseif os(OSX)
        import AppKit
        public typealias AssetImage = NSImage
        #endif

        import Foundation

        public enum Asset {
            static let image   = AssetImageSource.self
            static let gifData = AssetGIFDataSource.self
            static let color   = AssetColorSource.self
            static let data    = AssetDataSource.self
        }

        public enum AssetImageSource { }
        public enum AssetGIFDataSource { }
        public enum AssetColorSource { }
        public enum AssetDataSource { }

        public extension AssetImageSource {
        \(imageCode.sorted().joined(separator: "\n"))
        }

        public extension AssetGIFDataSource {
        \(gifCode.sorted().joined(separator: "\n"))
        }

        public extension AssetColorSource {
        \(dataCode.sorted().joined(separator: "\n"))
        }

        public extension AssetDataSource {
        \(colorCode.sorted().joined(separator: "\n"))
        }
        """
    }

}
