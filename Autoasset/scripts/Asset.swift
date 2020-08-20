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
        static let imageBundleName = "[image_bundle_name]"
        static let gifBundleName   = "[gif_bundle_name]"
        static let dataBundleName  = "[data_bundle_name]"
        static let colorBundleName = "[color_bundle_name]"
        static let images = "[images_code]"
        static let gifs   = "[gifs_code]"
        static let datas  = "[datas_code]"
        static let colors = "[colors_code]"
        static let fonts  = "[fonts_code]"
        static let mark   = "[mark]"
        static let name1   = "[name1]"
        static let name2   = "[name2]"
        static let variableName = "[variable_name]"
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
        /// 文件清理
        let xcassets = [config.images, config.gifs, config.datas, config.colors].compactMap({ $0 })
        Xcassets.deleteOutput(folders: xcassets)
        config.clear?.inputs.forEach({ try? FilePath(url: $0, type: .folder).delete() })

        /// 文件创建
        if let xcasset = config.images {
            try Xcassets(config: xcasset, use: .image).run().forEach { code in
                self.add(toImage: code)
            }
        }

        if let xcasset = config.gifs {
            try Xcassets(config: xcasset, use: .data).run().forEach { code in
                self.add(toGIF: code)
            }
        }

        if let xcasset = config.colors {
            try Xcassets(config: xcasset, use: .color).run().forEach { code in
                self.add(toColor: code)
            }
        }

        try output()
    }
    
    func output() throws {
        guard let template = config.template else {
            RunPrint("Config: asset/output 不能为空")
            return
        }

        var message = template.text
            .replacingOccurrences(of: Placeholder.images, with: imageCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.gifs, with: gifCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.datas, with: dataCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.colors, with: colorCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.fonts, with: fontCode.sorted().joined(separator: "\n"))

        if let config = config.images, let bundleName = config.bundleName {
           message = message.replacingOccurrences(of: Placeholder.imageBundleName, with: bundleName)
        }

        if let config = config.gifs, let bundleName = config.bundleName {
           message = message.replacingOccurrences(of: Placeholder.gifBundleName, with: bundleName)
        }

        if let config = config.datas, let bundleName = config.bundleName {
           message = message.replacingOccurrences(of: Placeholder.dataBundleName, with: bundleName)
        }

        if let config = config.colors, let bundleName = config.bundleName {
           message = message.replacingOccurrences(of: Placeholder.colorBundleName, with: bundleName)
        }

        let data = message.data(using: .utf8)
        let file = try FilePath(url: template.output, type: .file)
        try file.delete()
        try file.create(with: data)
    }

}

// MARK: - add
extension Asset {

    func format(name: String, use config: AssetModel.Xcasset?) -> String {
        var name = name
        if let prefix = config?.variablePrefix, prefix.isEmpty == false {
            name = "\(prefix)_\(name)"
        }

        var caseName = name.camelCased()

        if let prefix = config?.variablePrefix, prefix.isEmpty == false, prefix == "_" {
            caseName = "\(prefix)\(caseName)"
        }

        if name.first?.isNumber ?? false {
            caseName = "_\(caseName)"
            Warn.caseFirstCharIsNumber(caseName: name)
        }
        return caseName
    }

    func add(toColor code: AssetCode) {
        guard let text = config.template?.colorCode else {
            return
        }

        let str = text.replacingOccurrences(of: Placeholder.variableName, with: format(name: code.variableName, use: config.colors))
            .replacingOccurrences(of: Placeholder.mark, with: code.color.mark)
            .replacingOccurrences(of: Placeholder.name1, with: code.color.light)
            .replacingOccurrences(of: Placeholder.name2, with: code.color.dark)
        colorCode.append(str)
    }

    func add(toImage code: AssetCode) {
        guard let text = config.template?.imageCode else {
            return
        }
        imageCode.append(text
            .replacingOccurrences(of: Placeholder.variableName, with: format(name: code.variableName, use: config.images))
            .replacingOccurrences(of: Placeholder.name1, with: code.xcassetName))
    }
    
    func add(toGIF code: AssetCode) {
        guard let text = config.template?.gifCode else {
            return
        }
        gifCode.append(text
            .replacingOccurrences(of: Placeholder.variableName, with: format(name: code.variableName, use: config.gifs))
            .replacingOccurrences(of: Placeholder.name1, with: code.xcassetName))
    }
    
}
