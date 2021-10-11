//
//  File.swift
//  
//
//  Created by linhey on 2021/10/9.
//

import Foundation
import Stem
import Logging

public struct iOSCodeForBundle {
    
    public let folder: FilePath.Folder
    public let logger: Logger
    
    static var isCreated = false
    
    public init(folder: FilePath.Folder, logger: Logger) {
        self.folder = folder
        self.logger = logger
    }
    
    public func createDefaultFiles() throws {
        guard Self.isCreated == false else {
            return
        }
        
        let filename = "autoasset_bundle.swift"
        try? folder.file(name: filename).delete()
        
        let code = #"""
        import Foundation
        
        private class ASBundleFinder {}
        
        extension Foundation.Bundle {
            /// Returns the resource bundle associated with the current Swift module.
            static func module(name: String) -> Bundle {
                /**
                    Using the Swift Package Manager integration requires adding the "AutoAsset_Enable_SPM" macro to the Package file
                    使用 Swift Package Manager 集成需要在 Package 文件中添加 "AutoAsset_Enable_SPM" 宏
                    targets: [.target(..., swiftSettings: [.define("AutoAsset_Enable_SPM")])]
                */
                #if AutoAsset_Enable_SPM
                return .module
                #else
                if !name.isEmpty,
                   let url = Bundle(for: ASBundleFinder.self).url(forResource: name, withExtension: "bundle"),
                   let bundle = Bundle(url: url) {
                    return bundle
                }
                return .main
                #endif
            }
        }
        """#.data(using: .utf8)
        
        logger.info("创建: \(filename)")
        try folder.create(file: filename, data: code)
        Self.isCreated = true
    }
    
}
