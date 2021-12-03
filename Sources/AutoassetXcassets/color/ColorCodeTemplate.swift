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

struct ColorCodeTemplate {
    
    let folder: FilePath.Folder
    let logger: Logger
    
    func createDefaultFiles() throws {
        logger.info("创建: autoasset_color_protocol.swift")
        try folder.create(file: "autoasset_color_protocol.swift", data: template_protocol().data(using: .utf8))
        logger.info("创建: autoasset_color.swift")
        try folder.create(file: "autoasset_color.swift", data: template_core().data(using: .utf8))
    }
    
    func createListFile(colors: [Color]) throws {
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
        try folder.create(file: "autoasset_color_list.swift", data: str.data(using: .utf8))
    }
    
}

private extension ColorCodeTemplate {
    
    func listFileName(_ string: String) -> String {
        guard folder.file(name: string + ".swift").isExist else {
            return string + ".swift"
        }
        return listFileName(string + "_EX")
    }
    
}

private extension ColorCodeTemplate {
    
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
            
            #if canImport(UIKit)
            public let light: UIColor
            public let dark: UIColor
            public let system: UIColor
            #elseif canImport(AppKit)
            public let light: NSColor
            public let dark: NSColor
            public let system: NSColor
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

        private extension AutoAssetColor {
            
            #if canImport(UIKit)
            static func color(values: [CGFloat]) -> UIColor {
                return UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
            }
            #elseif canImport(AppKit)
            static func color(values: [CGFloat]) -> NSColor {
                return NSColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
            }
            #endif

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
            
        }
        """
    }
    
}
