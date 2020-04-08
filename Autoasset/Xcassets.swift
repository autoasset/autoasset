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
        return fileName.split(separator: "/").last?.split(separator: "@").first?.split(separator: ".").first?.description
    }

    func createDataContents(with fileNames: [String]) throws -> Data {
        var contents: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
        contents["data"] = fileNames.map { ["idiom": "universal", "filename": $0] }
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
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
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }

}

