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
    let byteCountFormatter = ByteCountFormatter()
    
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
    
    
    var imageReport = Report()
    var gifsReport  = Report()
    
    var imageCode: [String] = []
    var gifCode:   [String] = []
    var dataCode:  [String] = []
    var colorCode: [String] = []
    
    init(config: AssetModel) {
        self.config = config
        self.nameFormatter.enableTranslateVariableNameChineseToPinyin = Env.mode?.variables.enableTranslateVariableNameChineseToPinyin ?? false
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
        
        if let model = config.images {
            try runXcasset(title: "images", xcasset: model, type: .image) {
                self.add(report: &imageReport, config: model, template: config.template?.imageCode, code: $0, to: &imageCode)
            }
        }
        
        if let model = config.gifs {
            try runXcasset(title: "gifs", xcasset: model, type: .data) {
                self.add(report: &gifsReport, config: model, template: config.template?.gifCode, code: $0, to: &gifCode)
            }
        }
        
        if let model = config.colors {
            try runXcasset(title: "colors", xcasset: model, type: .color, callback: { self.add(toColor: $0) })
        }
        
        try output()

        if let report = config.images?.report, let filePath = try? FilePath(path: report, type: .file) {
            RunPrint.create(titleDesc: "command", title: "report: ", level: .info)
            RunPrint.create(row: "images path:" + relative(path: filePath.path))
            try? imageReport.write(to: filePath)
            RunPrint.createEnd()
        }
        
        if let report = config.gifs?.report, let filePath = try? FilePath(path: report, type: .file) {
            RunPrint.create(titleDesc: "command", title: "report: gifs", level: .info)
            RunPrint.create(row: "path:" + relative(path: filePath.path))
            try? gifsReport.write(to: filePath)
            RunPrint.createEnd()
        }
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
                    xcasset: AssetModel.Xcasset,
                    type: Xcassets.ResourceType,
                    callback: (AssetCode) -> Void) throws {
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
        guard let text = config.template?.colorCode, let color = code.output.color else {
            return
        }
        
        let variableName = nameFormatter.variableName(code.output.variableName, prefix: config.colors?.variablePrefix)
        let str = text.replacingOccurrences(of: Placeholder.variableName, with: variableName.uppercased())
            .replacingOccurrences(of: Placeholder.mark, with: color.mark)
            .replacingOccurrences(of: Placeholder.name1, with: color.light)
            .replacingOccurrences(of: Placeholder.name2, with: color.dark)
        colorCode.append(str)
    }
    
    
    func relative(path: String, basePath: String = Env.rootURL.path) -> String {
       return "." + path.st.deleting(prefix: basePath)
    }
    
    func add(report: inout Report,
             config: AssetModel.Xcasset,
             template: String?,
             code: AssetCode,
             to list: inout [String]) {
        guard let text = template else {
            return
        }
        
        let variableName = nameFormatter.variableName(code.output.variableName, prefix: nil)
        let folderName   = code.output.folder.attributes.name.split(separator: ".")[0].description
        
        if config.report != nil {
            let row = Report.Row()
            row.variableName     = .init(value: variableName)
            row.inputFilePaths   = .init(value: code.input.filePaths.map({ self.relative(path: $0.path) }))
            row.outputFolderName = .init(value: folderName)
            row.inputFilesSize   = .init(value: code.input.filePaths
                                            .compactMap({ $0.attributes.size })
                                            .reduce(0, { $0 + $1 }))
            row.inputFilesSizeDescription = .init(value: byteCountFormatter.string(fromByteCount: Int64(row.inputFilesSize.value)))
            row.outputFolderPath = .init(value: relative(path: code.output.folder.path))
            report.rows.append(row)
        }
        
        list.append(text.replacingOccurrences(of: Placeholder.variableName, with: variableName)
                        .replacingOccurrences(of: Placeholder.name1, with: folderName))
    }
    
    func add(toGIF code: AssetCode) {
        guard let text = config.template?.gifCode else {
            return
        }
        
        let variableName = nameFormatter.variableName(code.output.variableName, prefix: nil)
        let folderName   = code.output.folder.attributes.name.split(separator: ".")[0].description
        
        gifCode.append(text
                        .replacingOccurrences(of: Placeholder.variableName, with: variableName)
                        .replacingOccurrences(of: Placeholder.name1, with: folderName))
    }
    
}
