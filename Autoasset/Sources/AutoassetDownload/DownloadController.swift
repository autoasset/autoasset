//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import AutoassetModels
import Git
import Logging

public struct DownloadController {
    
    public let model: Download
    
    public init(model: Download) {
        self.model = model
    }
    
    public func run() throws {
        let git = Git()
        let logger = Logger(label: "git")
        try model.gits.forEach { item in
            let desc = [item.input, item.branch, item.output].joined(separator: " ")
            logger.info(.init(stringLiteral: desc))
            try git.clone(url: item.input,
                          options: [.singleBranch, .depth(1), .branch(item.branch)],
                          to: item.output)
        }
    }
}
