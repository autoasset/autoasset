//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/22.
//

import Foundation
import StemCrossPlatform

protocol XcassetsControllerProtocol {}

extension XcassetsControllerProtocol {
 
    func read(paths: [String], predicates: [FilePath.SearchPredicate]) throws -> [FilePath] {
        return try paths.compactMap({ try FilePath(path: $0) })
            .map({ path -> [FilePath] in
                switch path.type {
                case .file:
                    return [path]
                case .folder:
                    return try path.allSubFilePaths(predicates: predicates)
                }
            })
            .joined()
            .map({ $0 })
    }
    
}
