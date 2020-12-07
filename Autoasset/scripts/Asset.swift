//
//  Asset.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Asset {
    
    let config: AssetModel
    let nameFormatter = NameFormatter(split: [" ", "_", "-"])
    
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
    
    init(config: AssetModel) {
        self.config = config
    }
    
    func run() throws {
        /// 文件清理
        [config.codes,
         config.xcassets,
         config.images,
         config.gifs,
         config.datas,
         config.colors]
            .compactMap({ $0 })
            .forEach { try? FilePath(url: $0.output, type: .folder).delete() }
        
        if let resource = config.clear {
            RunPrint.create(titleDesc: "command", title: "clear", level: .info)
            try resource.inputs.forEach {
                RunPrint.create(row: "clearing")
                RunPrint.create(row: $0.path)
                try FilePath(url: $0, type: .folder).delete()
            }
            RunPrint.createEnd()
        }
        
        try runCopyFiles(title: "xcassets", resource: config.xcassets)
        try runCopyFiles(title: "codes", resource: config.codes)
        try runXcasset(title: "images", xcasset: config.images, type: .image, callback: { self.add(toImage: $0) })
        try runXcasset(title: "colors", xcasset: config.colors, type: .color, callback: { self.add(toColor: $0) })
        try runXcasset(title: "gifs", xcasset: config.gifs, type: .data, callback: { self.add(toGIF: $0) })
        
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

private extension Asset {

    func runCopyFiles(title: String, resource: AssetModel.Resource?) throws {
        guard let resource = resource else {
            return
        }
        RunPrint.create(titleDesc: "command", title: title, level: .info)
        let output = try FilePath(url: resource.output, type: .folder)
        try resource.inputs
            .compactMap({ try FilePath(url: $0, type: .folder) })
            .forEach {
                RunPrint.create(row: "copying")
                RunPrint.create(row: "from: \($0.path)")
                RunPrint.create(row: "to  : \(output.path)")
                try $0.copy(to: output)
            }
        RunPrint.createEnd()
    }
    
    func runXcasset(title: String,
                    xcasset: AssetModel.Xcasset?,
                    type: Xcassets.ResourceType,
                    callback: (AssetCode) -> Void) throws {
        guard let xcasset = xcasset else {
            return
        }
        
        RunPrint.create(titleDesc: "command", title: title, level: .info)
        try Xcassets(config: xcasset, use: type).run().forEach { code in
            callback(code)
        }
        RunPrint.createEnd()
    }
    
}

// MARK: - add
private extension Asset {
    
    func add(toColor code: AssetCode) {
        guard let text = config.template?.colorCode else {
            return
        }
        
        let variableName = nameFormatter.variableName(code.variableName, prefix: config.colors?.variablePrefix)
        let str = text.replacingOccurrences(of: Placeholder.variableName, with: variableName.uppercased())
            .replacingOccurrences(of: Placeholder.mark, with: code.color.mark)
            .replacingOccurrences(of: Placeholder.name1, with: code.color.light)
            .replacingOccurrences(of: Placeholder.name2, with: code.color.dark)
        colorCode.append(str)
    }
    
    func add(toImage code: AssetCode) {
        guard let text = config.template?.imageCode else {
            return
        }
        let variableName = nameFormatter.variableName(code.variableName, prefix: nil)
        imageCode.append(text
                            .replacingOccurrences(of: Placeholder.variableName, with: variableName)
                            .replacingOccurrences(of: Placeholder.name1, with: code.xcassetName))
    }
    
    func add(toGIF code: AssetCode) {
        guard let text = config.template?.gifCode else {
            return
        }
        let variableName = nameFormatter.variableName(code.variableName, prefix: nil)
        gifCode.append(text
                        .replacingOccurrences(of: Placeholder.variableName, with: variableName)
                        .replacingOccurrences(of: Placeholder.name1, with: code.xcassetName))
    }
    
}
