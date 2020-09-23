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

        return .init(template: JSON(["text": templateText,
                                     "gif_code": gif_code,
                                     "image_code": image_code,
                                     "color_code": color_code]))
    }()


    private static let templateText =
        """

import UIKit

fileprivate class RBundle {

    enum `Type`: String {
        case none
        case main
        case image = "image_bundle_name"
        case gif   = "gif_bundle_name"
        case data  = "data_bundle_name"
        case color = "color_bundle_name"

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

    static func bundle(for type: `Type`) -> Bundle {
        switch type {
        case .main:
            return .main
        case .none:
            return Bundle(for: RBundle.self)
        default:
            if type.name == type.rawValue {
                return bundle(for: .none)
            }

            guard let url = bundle(for: .none).url(forResource: type.name, withExtension: "bundle")
                  , let bundle = Bundle(url: url) else {
                return .main
            }

            return bundle
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

    class Color {

        public enum State {
            case light
            case dark
        }

        public private(set) static var state: State = .light

        public static func enable(_ state: State) {
            self.state = state
        }

        let hex1: Int64
        let hex2: Int64

        /// 十六进制色: 0x666666
        ///
        /// - Parameter RGBValue: 十六进制颜色
        func values(hex value: Int64) -> [CGFloat] {
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

        init(light hex1: Int64, dark hex2: Int64) {
            self.hex1 = hex1
            self.hex2 = hex2
        }

    }

}

#if canImport(UIKit)
import UIKit

public extension AssetSource.Color {

    private func color(values: [CGFloat]) -> UIColor {
        return UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
    }

    func light() -> UIColor { color(values: values(hex: hex1)) }
    func dark()  -> UIColor { color(values: values(hex: hex2)) }
    func color() -> UIColor {
        switch Self.state {
        case .dark: return dark()
        case .light: return light()
        }
    }

    func light() -> CGColor { light().cgColor }
    func dark()  -> CGColor { dark().cgColor }
    func color() -> CGColor { color().cgColor }

    func light() -> CIColor { light().ciColor }
    func dark()  -> CIColor { dark().ciColor }
    func color() -> CIColor { color().ciColor }

}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension AssetSource.Color {

    private func color(values: [CGFloat]) -> NSColor {
        return NSColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
    }

    func light() -> NSColor { color(values: values(hex: hex1)) }
    func dark()  -> NSColor { color(values: values(hex: hex2)) }
    func color() -> NSColor {
        switch Self.state {
        case .dark: return dark()
        case .light: return light()
        }
    }

}
#endif

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension AssetSource.Color {

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func light() -> SwiftUI.Color { SwiftUI.Color(light()) }
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func dark()  -> SwiftUI.Color { SwiftUI.Color(dark()) }
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func color() -> SwiftUI.Color { SwiftUI.Color(color()) }

}
#endif

public protocol RImageProtocol {}
public protocol RGIFProtocol {}
public protocol RColorProtocol {}
public protocol RDataProtocol {}

public enum R {

    public static let images = Image.self
    public static let gifs   = GIF.self
    public static let colors = Color.self
    public static let datas  = Data.self

    public enum Image: RImageProtocol {}
    public enum GIF: RGIFProtocol {}
    public enum Color: RColorProtocol {}
    public enum Data: RDataProtocol {}

}

public typealias Asset  = R.Image
public typealias Colors = R.Color

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
