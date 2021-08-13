//
//  File.swift
//  
//
//  Created by linhey on 2021/8/9.
//

import Foundation
import StemCrossPlatform
import AutoassetModels
import VariablesMaker
import Logging

struct ImageCodeTemplate {
    
    let folder: FilePath.Folder
    let logger: Logger
    
    func createDefaultFiles() throws {
        let filename1 = "autoasset_image_protocol.swift"
        logger.info("创建: \(filename1)")
        try folder.create(file:filename1, data: template_protocol().data(using: .utf8))
        
        let filename2 = "autoasset_image.swift"
        logger.info("创建: \(filename2)")
        try folder.create(file: filename2, data: template_core().data(using: .utf8))
    }
    
    func createListFile(names: [String], in resource: Xcassets.Image) throws {
        guard names.isEmpty == false else {
            return
        }
        let bundle_name = resource.bundle_name == nil ? "nil" : "\"\(resource.bundle_name!)\""
        let list = names.map({ item in
            return (variable: NameFormatter().variable(item), named: "\(resource.prefix)\(item)")
        }).sorted(by: { lhs, rhs in
            return lhs.variable < rhs.variable
        }).map({ item -> String in
            return "   static var \(item.variable): Self { self.init(named: \"\(item.named)\", in: \(bundle_name)) }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAssetImageProtocol {\n\(list)\n}"
        let filename = listFileName("autoasset_image_list_\(resource.bundle_name ?? "main")")
        logger.info("创建: \(filename)")
        try folder.create(file: filename, data: str.data(using: .utf8))
    }
    
}

private extension ImageCodeTemplate {
    
    func listFileName(_ string: String) -> String {
        guard folder.file(name: string + ".swift").isExist else {
            return string + ".swift"
        }
        return listFileName(string + "_EX")
    }
    
}

private extension ImageCodeTemplate {
    
    func template_protocol() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif
        
        public protocol AutoAssetImageProtocol {
            init(named: String, in bundle: String?)
            #if canImport(UIKit)
            func value() -> UIImage
            #elseif canImport(AppKit)
            func value() -> NSImage
            #endif
        }
        """
    }
    
    func template_core() -> String {
        #"""
            #if canImport(UIKit)
            import UIKit
            #elseif canImport(AppKit)
            import AppKit
            #endif
            
            public class AutoAssetImage: AutoAssetImageProtocol {
            
            public let named: String
            public let bundle: String?
            
            static var bundleMap = [String: Bundle]()
            
            required public init(named: String, in bundle: String?) {
            self.named = named
            self.bundle = bundle
            }
            
            #if canImport(UIKit)
            public func value() -> UIImage {
            guard let bundleName = bundle else {
            if let image = UIImage(named: named) {
            return image
            }
            assertionFailure("can't find image: \(named) in bundle: \(bundle ?? "main")")
            return UIImage()
            }
            
            if let bundle = Self.bundleMap[bundleName] {
            if let image = UIImage(named: named, in: bundle, compatibleWith: nil) {
            return image
            }
            assertionFailure("can't find image: \(named) in bundle: \(bundleName)")
            return UIImage()
            }
            
            if let url = Bundle(for: Self.self).url(forResource: bundle, withExtension: "bundle"),
            let bundle = Bundle(url: url),
            let image = UIImage(named: named, in: bundle, compatibleWith: nil) {
            Self.bundleMap[bundleName] = bundle
            return image
            }
            
            assertionFailure("can't find image: \(named) in bundle: \(bundle ?? "main")")
            return UIImage()
            }
            
            #elseif canImport(AppKit)
            func value() -> NSImage {
            return .init(imageLiteralResourceName: named)
            }
            #endif
            }
            
            """#
    }
    
}
