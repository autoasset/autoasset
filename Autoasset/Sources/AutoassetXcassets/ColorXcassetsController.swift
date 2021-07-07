// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import StemCrossPlatform
import AutoassetModels
import Logging

struct ColorXcassetsController: XcassetsControllerProtocol {
    
    let asset: Xcassets
    var resources: [Xcassets.Color] { asset.colors }
    private let logger = Logger(label: "colors")
    
    struct Color: Hashable {
        let light: StemColor
        let dark: StemColor
        
        init?(json: JSON) {
            self.light = StemColor(hex: json["light"].string ?? json["any"].stringValue)
            self.dark  = StemColor(hex: json["dark"].string ?? json["any"].stringValue)
        }
    }
    
    func run() throws {
        setDefaultFiles()
        try resources.forEach { try task(with: $0) }
    }
    
    func task(with resource: Xcassets.Color) throws {
        var unique = Set<StemColor>()
        let folder = try FilePath.Folder(path: resource.output)
        let colors = try read(paths: resource.inputs, predicates: [.skipsHiddenFiles, .custom({ $0.type == .file })])
            .map { FilePath.File(url: $0.url) }
            .map { try JSON(data: $0.data()).arrayValue }
            .joined()
            .compactMap { Color(json: $0) }
            .filter({ unique.insert($0.light).inserted })
            .map({ (color: $0, try conversion(color: $0, resource: resource)) })
            .map({ (color, data) -> Color in
                let name = color.light.hexString(.digits6, prefix: .none)
                let imageset = try folder.create(folder: "\(name).colorset")
                logger.info(.init(stringLiteral: imageset.attributes.name))
                try imageset.create(file: "Contents.json", data: data)
                return color
            })
        setTemplateList(colors: colors)
    }
    
}

extension ColorXcassetsController {
    
    func setDefaultFiles() {
        guard let output = asset.template?.output else {
            return
        }
        do {
            let folder = try FilePath.Folder(path: output)
            try folder.create(file: "autoasset_color_protocol.swift", data: template_protocol().data(using: .utf8))
            try folder.create(file: "autoasset_color.swift", data: template_core().data(using: .utf8))
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func setTemplateList(colors: [Color]) {
        guard let output = asset.template?.output else {
            return
        }
        let list = colors.map({ item -> String in
            let light_hex  = item.light.hexString(prefix: .none)
            let dark_hex   = item.dark.hexString(prefix: .none)
            let light_values = item.light.rgbSpace.intUnpack
            let dark_values  = item.dark.rgbSpace.intUnpack
            return ["   ///",
                    "light: red: \(light_values.red) green: \(light_values.green) blue: \(light_values.blue)",
                    "dark: red: \(dark_values.red) green: \(dark_values.green) blue: \(dark_values.blue)"]
                .joined(separator: " | ")
            + "\n"
            + "   static var _\(light_hex): Self { Self.init(light: 0x\(light_hex), dark: 0x\(dark_hex)) }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAssetColorProtocol {\n\(list)\n}"
        do {
            let folder = try FilePath.Folder(path: output)
            try folder.create(file: "autoasset_color_list.swift", data: str.data(using: .utf8))
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func template_protocol() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif

        public protocol AutoAssetColorProtocol {
            init(light: Int64, dark: Int64)
            #if canImport(UIKit)
            func value() -> UIColor
            #elseif canImport(AppKit)
            func value() -> NSColor
            #endif
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

        public class AutoAssetColor: AutoAssetColorProtocol {
            
            public enum State {
                case light
                case dark
                case system
            }
            
            #if canImport(UIKit)
            let light: UIColor
            let dark: UIColor
            let system: UIColor
            #elseif canImport(AppKit)
            let light: NSColor
            let dark: NSColor
            let system: NSColor
            #endif
            
            public private(set) static var state: State = .system
            
            public static func enable(_ state: State) {
                self.state = state
            }
            
            /// 十六进制色: 0x666666
            ///
            /// - Parameter RGBValue: 十六进制颜色
            static func values(hex value: Int64) -> [CGFloat] {
                var hex = value
                var count = 0
                
                while count <= 8, hex > 0 {
                    hex = hex >> 4
                    count += 1
                    if count > 8 { break }
                }
                
                let divisor = CGFloat(255)
                
                if count <= 6 {
                    let red     = CGFloat((value & 0xFF0000) >> 16) / divisor
                    let green   = CGFloat((value & 0x00FF00) >>  8) / divisor
                    let blue    = CGFloat( value & 0x0000FF       ) / divisor
                    return [red, green, blue, 1]
                } else {
                    assertionFailure("StemColor: 位数错误, 只支持 6 或 8 位, count: \\(count)")
                }
                
                return [0,0,0,1]
            }
            
            #if canImport(UIKit)
            static func color(values: [CGFloat]) -> UIColor {
                return UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
            }
            #elseif canImport(AppKit)
            static func color(values: [CGFloat]) -> NSColor {
                return NSColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
            }
            #endif
            
            public required init(light hex1: Int64, dark hex2: Int64) {
                let color1 = Self.color(values: Self.values(hex: hex1))
                let color2 = Self.color(values: Self.values(hex: hex2))
                self.light  = color1
                self.dark   = color2
                
                #if canImport(UIKit)
                if #available(iOS 13.0, *) {
                    self.system = .init(dynamicProvider: { $0.userInterfaceStyle == .dark ? color2 : color1 })
                } else {
                    self.system = color1
                }
                #elseif canImport(AppKit)
                self.system = color1
                #endif
            }
        }

        public extension AutoAssetColor {
            #if canImport(UIKit)
            func value() -> UIColor { return system }
            #elseif canImport(AppKit)
            func value() -> NSColor { return system }
            #endif
        }
        """
    }
    
}

extension ColorXcassetsController {
    
    func conversion(color: Color, resource: Xcassets.Color) throws -> Data {
        var colors = [[String: Any]]()
        
        if color.light == color.dark {
            var element = [String: Any]()
            element["color-space"] = resource.space
            element["components"] = self.components(color.light)
            colors.append(["idiom": "universal", "color": element])
        } else {
            
            var element_light = [String: Any]()
            element_light["color-space"] = resource.space
            element_light["components"] = self.components(color.light)
            colors.append(["idiom": "universal", "color": element_light])
            
            var element_dark = [String: Any]()
            element_dark["color-space"] = resource.space
            element_dark["components"] = self.components(color.dark)
            colors.append(["idiom": "universal", "color": element_dark])
            
            var appearance_light = [String: Any]()
            appearance_light["appearance"] = "luminosity"
            appearance_light["value"] = "light"
            
            var appearance_dark = [String: Any]()
            appearance_dark["appearance"] = "luminosity"
            appearance_dark["value"] = "dark"
            
            colors.append(["appearances": [appearance_light], "idiom": "universal", "color": element_light])
            colors.append(["appearances": [appearance_dark], "idiom": "universal", "color": element_dark])
            
        }
        
        let contents: [String : Any] = ["colors": colors,
                                        "info": ["version": 1, "author": "xcode"],
                                        "properties": ["localizable": true]]
        
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }
    
    func components(_ color: StemColor) -> [String: String] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.formatWidth = 4
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        
        return ["alpha": formatter.string(from: .init(value: color.alpha))!,
                "blue" : formatter.string(from: .init(value: color.rgbSpace.blue))!,
                "green": formatter.string(from: .init(value: color.rgbSpace.green))!,
                "red"  : formatter.string(from: .init(value: color.rgbSpace.red))!]
    }
    
}
