//
//  File.swift
//  
//
//  Created by linhey on 2021/7/8.
//

import Foundation
import Logging
import StemCrossPlatform
import VariablesMaker
import ASError
import AutoassetModels
import AutoassetiOSCode

public struct IconFontController {
    
    private let logger = Logger(label: "iconfont")
    private let iconfont: IconFont
    private let variablesMaker: VariablesMaker

    public init(_ iconfont: IconFont, variables: Variables) throws {
        self.iconfont = iconfont
        self.variablesMaker = VariablesMaker(variables)
    }
    
    public func run() throws {
        let folder = try FilePath.Folder(path: try variablesMaker.textMaker(iconfont.package))

        guard let source = try folder
                .subFilePaths()
                .first(where: { $0.attributes.name.hasSuffix(".json") })
                .flatMap({ try FilePath.File(url: $0.url).data() })
                .flatMap({ try JSON(data: $0) })
                .flatMap({ IconFont.Model(from: $0) }) else {
            return
        }
        
        guard let font = try folder
                .subFilePaths()
                .first(where: { $0.attributes.name.hasSuffix(try variablesMaker.textMaker(iconfont.font.fontType.rawValue)) })
                .flatMap({ FilePath.File(url: $0.url) }) else {
            return
        }
                    
        for template in iconfont.templates {
            switch template {
            case .flutter(let template):
                let target = try FilePath.File(path: try variablesMaker.textMaker(iconfont.font.output))
                _ = try? target.delete()
                _ = try target.parentFolder()?.create()
                try font.replace(target)
                
                let parse = FlutterParse(model: source, template: template)
                let file = try FilePath.File(path: try variablesMaker.textMaker(template.output))
                try file.delete()
                try file.create(with: variablesMaker.textMaker(parse.code).data(using: .utf8))
            case .iOS(let template):
                let outputFolder = try FilePath.Folder(path: try variablesMaker.textMaker(template.output))
                let parse = SwiftParse(model: source,
                                       template: template,
                                       folder: outputFolder,
                                       variablesMaker: variablesMaker)
                
                try iOSCodeForBundle(folder: outputFolder, logger: logger).createDefaultFiles()
                try parse.createDefaultFiles()
                try parse.createListFile()
            }
        }

    }
    
}
