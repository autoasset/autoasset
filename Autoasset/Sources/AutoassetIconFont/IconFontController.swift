//
//  File.swift
//  
//
//  Created by linhey on 2021/7/8.
//

import Foundation
import AutoassetModels
import StemCrossPlatform
import Logging
import VariablesMaker
import ASError

public struct IconFontController {
    
    private let logger = Logger(label: "iconfont")
    private let iconfont: IconFont
    private let folder: FilePath.Folder
    
    public init(_ iconfont: IconFont) throws {
        self.iconfont = iconfont
        self.folder = try .init(path: iconfont.input)
    }
    
    public func run() throws {
        let source = try self.folder
            .subFilePaths()
            .first(where: { $0.attributes.name.hasSuffix(".json") })
            .flatMap({ try FilePath.File(url: $0.url).data() })
            .flatMap({ try JSON(data: $0) })
            .flatMap({ IconFont.Model(from: $0) })
    }
    
}
