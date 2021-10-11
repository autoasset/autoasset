//
//  File.swift
//
//
//  Created by linhey on 2021/8/9.
//

import Foundation
import Stem
import AutoassetModels
import VariablesMaker
import Logging

struct DataCodeTemplate {
    
    enum Named: String {
        
        case data = "data"
        case gifs = "gifs"
        case iconfonts = "iconfonts"
        
        var className: String {
            switch self {
            case .data: return "Data"
            case .gifs: return "GIF"
            case .iconfonts: return "IconFont"
            }
        }
        
    }
    
    let named: Named
    let folder: FilePath.Folder
    let logger: Logger
    
    func createDefaultFiles() throws {
        let filename1 = "autoasset_\(named.rawValue)_protocol.swift"
        logger.info("创建: \(filename1)")
        try folder.create(file:filename1, data: template_protocol().data(using: .utf8))
        
        let filename2 = "autoasset_\(named.rawValue).swift"
        logger.info("创建: \(filename2)")
        try folder.create(file: filename2, data: template_core().data(using: .utf8))
    }
    
    func createListFile(names: [String], in resource: Xcassets.Data) throws {
        guard names.isEmpty == false else {
            return
        }
        let bundle_name = resource.bundle_name == nil ? "nil" : "\"\(resource.bundle_name!)\""
        let list = names.map({ item in
            return (variable: NameFormatter().variable(item), named: "\(resource.prefix)\(item)")
        }).sorted(by: { lhs, rhs in
            return lhs.variable < rhs.variable
        }).map({ item -> String in
            return "   static var \(item.variable): Self { .init(named: \"\(item.named)\", in: \(bundle_name)) }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAsset\(named.className)Protocol {\n\(list)\n}"
        let filename = listFileName("autoasset_\(named.rawValue)_list_\(resource.bundle_name ?? "main")")
        logger.info("创建: \(filename)")
        try folder.create(file: filename, data: str.data(using: .utf8))
    }
    
}

private extension DataCodeTemplate {
    
    func listFileName(_ string: String) -> String {
        guard folder.file(name: string + ".swift").isExist else {
            return string + ".swift"
        }
        return listFileName(string + "_EX")
    }
    
}

private extension DataCodeTemplate {
    
    func template_protocol() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif

        public protocol AutoAsset\(named.className)Protocol {
            init(named: String, in bundle: String?)
            func value() -> Data
        }
        """
    }
    
    func template_core() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif

        public class AutoAsset\(named.className): AutoAsset\(named.className)Protocol {
            public let named: String
            public let bundle: String?
            
            public required init(named: String, in bundle: String?) {
                self.named = named
                self.bundle = bundle
            }
            
            @available(iOS 9.0, macOS 10.11, tvOS 6.0, watchOS 2.0, *)
            public func value() -> Foundation.Data {
                guard let bundle = bundle,
                      let data = NSDataAsset(name: named, bundle: Bundle.module(name: bundle))?.data else {
                    assertionFailure("can't find data: \\(named) in bundle: \\(bundle ?? "")")
                    return Foundation.Data()
                }
                return data
            }
        }

        """
    }
    
}
