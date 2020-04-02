//
//  Asset.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

fileprivate extension String {
    func camelCased() -> String {
        return self
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
            .split(separator: "_")
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
}

class AssetComponents {

}

class Asset {
    
    static let shared = Asset()
    
    var imageCode: [String] = []
    var gifCode:   [String] = []
    var dataCode:  [String] = []
    var colorCode: [String] = []
    var fontCode:  [String] = []
    
    var isUseInLibrary: Bool = false
    var bundleName: String = "Asset"
    
    func addGIFCode(with name: String) -> Warn? {
        if name.first?.isNumber ?? false {
            let caseName = name.camelCased()
            gifCode.append("    static var _\(caseName): Data { NSDataAsset(name: \"\(name)\")!.data }")
            return Warn("首字母不能为数字: \(caseName), 已更替为 _\(caseName)")
        }else {
            gifCode.append("    static var \(name.camelCased()): Data { NSDataAsset(name: \"\(name)\")!.data }")
            return nil
        }
    }
    
    func addImageCode(with name: String) -> Warn? {
        if name.first?.isNumber ?? false {
            let caseName = name.camelCased()
            imageCode.append("    static var _\(caseName): AssetImage { AssetImage(asset: \"\(name)\") }")
            return Warn("首字母不能为数字: \(caseName), 已更替为 _\(caseName)")
        }else {
            imageCode.append("    static var \(name.camelCased()): AssetImage { AssetImage(asset: \"\(name)\") }")
            return nil
        }
    }
    
    func createTemplate(to url: URL) throws {
        let staticCode = """
        
        fileprivate class AssetBundle { }
        
        extension AssetImage {
        
        static let bundle = Bundle(path: Bundle(for: AssetBundle.self).resourcePath!.appending("/\(bundleName).bundle"))!
        
        convenience init(asset named: String) {
        self.init(named: named, in: UIImage.bundle, compatibleWith: nil)!
        }
        }
        """
        
        let frameworkCode = """
        extension AssetImage {
            convenience init(asset named: String) {
                self.init(named: named)!
            }
        }
        """
        
        try """
            #if os(iOS) || os(tvOS) || os(watchOS)
            import UIKit
            public typealias AssetImage = UIImage
            #elseif os(OSX)
            import AppKit
            public typealias AssetImage = NSImage
            #endif

            import Foundation

            \(isUseInLibrary ? staticCode : frameworkCode)

            public enum Asset {
            public static let image   = AssetImageSource.self
            public static let gifData = AssetGIFDataSource.self
            public static let color   = AssetColorSource.self
            public static let data    = AssetDataSource.self
            }

            public enum AssetImageSource { }
            public enum AssetGIFDataSource { }
            public enum AssetColorSource { }
            public enum AssetDataSource { }

            public extension AssetImageSource {
            \(imageCode.sorted().joined(separator: "\n"))
            }

            public extension AssetGIFDataSource {
            \(gifCode.sorted().joined(separator: "\n"))
            }

            public extension AssetColorSource {
            \(dataCode.sorted().joined(separator: "\n"))
            }

            public extension AssetDataSource {
            \(colorCode.sorted().joined(separator: "\n"))
            }
            """.data(using: .utf8)?.write(to: url)
    }
    
}
