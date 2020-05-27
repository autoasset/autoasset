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
        let splitChars = [" ", "-", "_"]
        var words = [String]()
        var buffer = ""
        
        for index in 0..<count {
            let char = self[String.Index(utf16Offset: index, in: self)]
            
            if splitChars.contains(char.description) {
                if buffer.isEmpty == false {
                    words.append(buffer)
                    buffer = ""
                }
                continue
            }
            
            if char.uppercased() == char.description, buffer.isEmpty == false {
                words.append(buffer)
                buffer = char.description
                continue
            }
            
            buffer.append(char)
        }
        
        words.append(buffer)
        return words.enumerated().map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }.joined()
    }
}

class Asset {
    
    let config: AssetModel

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
        static let variableName = "[variable_name]"
        static let name = "[name]"
    }
    
    var imageCode: [String] = []
    var gifCode:   [String] = []
    var dataCode:  [String] = []
    var colorCode: [String] = []
    var fontCode:  [String] = []

    init(config: AssetModel) {
        self.config = config
    }

    func run() throws {
        let xcassets = [config.images, config.gifs, config.datas, config.colors].compactMap({ $0 })
        Xcassets.deleteOutput(folders: xcassets)
        
        if let xcasset = config.images {
            try Xcassets(config: xcasset, use: .image).run().forEach { name in
                self.add(toImage: name)
            }
        }

        if let xcasset = config.gifs {
            try Xcassets(config: xcasset, use: .data).run().forEach { name in
                self.add(toGIF: name)
            }
        }

        try output()
    }
    
    func output() throws {
        guard let template = config.template else {
            RunPrint("Config: asset/output 不能为空")
            return
        }
        try template.text
            .replacingOccurrences(of: Placeholder.images, with: imageCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.gifs, with: gifCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.datas, with: dataCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.colors, with: colorCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.fonts, with: fontCode.sorted().joined(separator: "\n"))
            .data(using: .utf8)?
            .write(to: template.output, options: [.atomicWrite])
    }

}

// MARK: - add
extension Asset {

    func format(name: String) -> String {
        var caseName = name.camelCased()
        if name.first?.isNumber ?? false {
            caseName = "_\(caseName)"
            Warn.caseFirstCharIsNumber(caseName: name)
        }
        return caseName
    }

    func add(toImage name: String) {
        guard let text = config.template?.imageCode else {
            return
        }
        imageCode.append(text
            .replacingOccurrences(of: Placeholder.variableName, with: format(name: name))
            .replacingOccurrences(of: Placeholder.name, with: format(name: name)))
    }
    
    func add(toGIF name: String) {
        guard let text = config.template?.gifCode else {
            return
        }

        gifCode.append(text
            .replacingOccurrences(of: Placeholder.variableName, with: format(name: name))
            .replacingOccurrences(of: Placeholder.name, with: format(name: name)))
    }
    
}
