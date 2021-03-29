//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import AutoassetModels
import StemCrossPlatform
import Logging

public struct TidyController {
    
    public let model: Tidy
    private let logger = Logger(label: "tidy")
    
    public init(model: Tidy) {
        self.model = model
    }
    
    public func run(name: String) throws {
        try clearTask(name)
        try copyTask(name)
    }
    
}


extension TidyController {
    
    func create() {
        
    }
    
    func clearTask(_ name: String) throws {
        model.clears.first(where: { $0.name == name })?.inputs.forEach {
            do {
                logger.info("正在移除: \($0)")
                try FilePath(path: $0).delete()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
    
    func copyTask(_ name: String) throws {
        guard let item = model.copies.first(where: { $0.name == name }) else {
            return
        }
        let output = try FilePath(path: item.output, type: .folder)
        for input in item.inputs.compactMap({ try? FilePath(path: $0) }) {
            logger.info("正在复制: \(output.path)")
            try input.copy(to: output)
        }
        
    }
    
}
