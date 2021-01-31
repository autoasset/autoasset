//
//  Template.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/24.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Yams
import Stem

class ASTemplate { }

// MARK: - asset
extension ASTemplate {
    
    static let asset: AssetModel.Template = {
        let gif_code   = "    static var [variable_name]: AssetSource.GIF { .init(asset: \"[name1]\") }"
        let image_code = "    static var [variable_name]: AssetSource.Image { .init(asset: \"[name1]\") }"
        let color_code = "    /// [mark]\n    static var [variable_name]: AssetSource.Color { .init(light: [name1], dark: [name2]) }"
        
        return .init(template: JSON(["core": templateCore,
                                     "text": templateText,
                                     "gif_code": gif_code,
                                     "image_code": image_code,
                                     "color_code": color_code]))
    }()
    
    private static let templateCore = """
import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

class RBundle {
    
    enum BundleType: String {
        case none
        case main
        case image = "image_bundle_name"
        case gif   = "gif_bundle_name"
        case data  = "data_bundle_name"
        case color = "color_bundle_name"
    }
    
    static func bundle(for type: BundleType) -> Bundle {
        switch type {
        case .main:
            return .main
        case .none:
            return Bundle(for: RBundle.self)
        default:
            if type.name == type.rawValue {
                return bundle(for: .none)
            }
            
            if let url = bundle(for: .none).url(forResource: type.name, withExtension: "bundle"),
               let bundle = Bundle(url: url) {
                return bundle
            }
            
            if let url = bundle(for: .main).url(forResource: type.name, withExtension: "bundle"),
               let bundle = Bundle(url: url) {
                return bundle
            }
            
            return .main
        }
    }
    
}

public class AssetSource {
    
    public class Base {
        public let name: String
        init(asset named: String) {
            self.name = named
        }
    }
    
}

public extension AssetSource {
    
    class Image: Base { }
    
}

public extension AssetSource {
    
    class Data: Base {
        
        @available(iOS 9.0, macOS 10.11, tvOS 6.0, watchOS 2.0, *)
        public func value() -> Foundation.Data {
            for type in [.data, .none, .main] as [RBundle.BundleType] {
                if let value = NSDataAsset(name: name, bundle: RBundle.bundle(for: type)) {
                    return value.data
                }
            }
            assert(false, "未查询到相应资源")
            return Foundation.Data()
        }
        
    }
    
    class GIF: AssetSource.Data {
        
        @available(iOS 9.0, macOS 10.11, tvOS 6.0, watchOS 2.0, *)
        public override func value() -> Foundation.Data {
            for type in [.gif, .none, .main] as [RBundle.BundleType] {
                if let value = NSDataAsset(name: name, bundle: RBundle.bundle(for: type)) {
                    return value.data
                }
            }
            assert(false, "未查询到相应资源")
            return Foundation.Data()
        }
        
    }
    
}

public extension AssetSource {
    
    class Color {
        
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
            } else if count <= 8 {
                let red     = CGFloat((Int64(value) & 0xFF000000) >> 24) / divisor
                let green   = CGFloat((Int64(value) & 0x00FF0000) >> 16) / divisor
                let blue    = CGFloat((Int64(value) & 0x0000FF00) >>  8) / divisor
                let alpha   = CGFloat( Int64(value) & 0x000000FF       ) / divisor
                return [red, green, blue, alpha]
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
        
        init(light hex1: Int64, dark hex2: Int64) {
            if hex1 == hex2 {
                let color = Self.color(values: Self.values(hex: hex1))
                self.light  = color
                self.dark   = color
                self.system = color
            } else {
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
    }
    
}

public extension AssetSource.Color {
    
    #if canImport(UIKit)
    func value() -> UIColor { return system }
    #elseif canImport(AppKit)
    func value() -> NSColor { return system }
    #endif
    
    #if canImport(SwiftUI)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func value() -> SwiftUI.Color { return .init(system) }
    #endif
    
}


public extension AssetSource.Image {
    
    #if canImport(UIKit)
    func value() -> UIImage {
        for type in [.image, .none, .main] as [RBundle.BundleType] {
            if let value = UIImage(named: name, in: RBundle.bundle(for: type), compatibleWith: nil) {
                return value
            }
        }
        assert(false, "未查询到相应资源")
        return UIImage()
    }
    #elseif canImport(AppKit)
    func value() -> NSImage {
        for _ in [.image, .none, .main] as [RBundle.BundleType] {
            if let value = NSImage(named: name) {
                return value
            }
        }
        assert(false, "未查询到相应资源")
        return NSImage()
    }
    #endif
    
    #if canImport(SwiftUI)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func value() -> SwiftUI.Image {
        #if canImport(UIKit)
        return .init(uiImage: value())
        #elseif canImport(AppKit)
        return .init(nsImage: value())
        #endif
    }
    #endif
}

public enum R {
    public enum Image: RImageProtocol {}
    public enum GIF: RGIFProtocol {}
    public enum Color: RColorProtocol {}
    public enum Data: RDataProtocol {}
    
    public static let images = Image.self
    public static let gifs   = GIF.self
    public static let colors = Color.self
    public static let datas  = Data.self
}

"""
    
    private static let templateText =
        """
extension RBundle.BundleType {
    var name: String {
        switch self {
        case .none, .main:  return rawValue
        case .image: return "[image_bundle_name]"
        case .gif:   return "[gif_bundle_name]"
        case .data:  return "[data_bundle_name]"
        case .color: return "[color_bundle_name]"
        }
    }
}

public protocol RImageProtocol {}
public protocol RGIFProtocol {}
public protocol RColorProtocol {}
public protocol RDataProtocol {}

public extension RImageProtocol {
[images_code]
}

public extension RGIFProtocol {
[gifs_code]
}

public extension RColorProtocol {
[colors_code]
}

public extension RDataProtocol {
[datas_code]
}

"""
    
}
