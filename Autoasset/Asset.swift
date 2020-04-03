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

    let config: Config.Asset

    enum Placeholder {
        static let images = "[images_code]"
        static let gifs   = "[gifs_code]"
        static let datas  = "[datas_code]"
        static let colors = "[colors_code]"
        static let fonts  = "[fonts_code]"
    }

    var imageCode: [String] = []
    var gifCode:   [String] = []
    var dataCode:  [String] = []
    var colorCode: [String] = []
    var fontCode:  [String] = []

    init(config: Config.Asset) {
        self.config = config
    }

    func output() throws {
        guard let output = config.outputPath else {
            throw RunError(message: "Config: asset/output_path 不能为空")
        }

        var template = ""

        if let path = config.templatePath?.path {
            template = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            template = createTemplate()
        }

        try template
            .replacingOccurrences(of: Placeholder.images, with: imageCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.gifs, with: gifCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.datas, with: dataCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.colors, with: colorCode.sorted().joined(separator: "\n"))
            .replacingOccurrences(of: Placeholder.fonts, with: fontCode.sorted().joined(separator: "\n"))
            .data(using: .utf8)?.write(to: output)
    }
    

    
}

// MARK: - add
extension Asset {

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

}

private extension Asset {

    func createTemplate() -> String {
        let staticCode = """
        fileprivate class AssetBundle { }

        extension AssetImage {

        static let bundle = Bundle(path: Bundle(for: AssetBundle.self).resourcePath!.appending("Asset.bundle"))!

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

        return """
            #if os(iOS) || os(tvOS) || os(watchOS)
            import UIKit
            public typealias AssetImage = UIImage
            #elseif os(OSX)
            import AppKit
            public typealias AssetImage = NSImage
            #endif

            import Foundation

            \(config.isUseInPod ? staticCode : frameworkCode)

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
            [images_code]
            }

            public extension AssetGIFDataSource {
            [gifs_code]
            }

            public extension AssetColorSource {
            [colors_code]
            }

            public extension AssetDataSource {
            [datas_code]
            }
            """
    }

}
