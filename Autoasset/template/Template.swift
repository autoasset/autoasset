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
        let text = """
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

    public class Color {

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

        public var color: UIColor {
            switch Self.state {
            case .dark: return dark
            case .light: return light
            }
        }
        public var light: UIColor { color(hex: hex1) }
        public var dark: UIColor  { color(hex: hex2) }

        /// 十六进制色: 0x666666
        ///
        /// - Parameter RGBValue: 十六进制颜色
        func color(hex value: Int64) -> UIColor {

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
                return .init(red: red, green: green, blue: blue, alpha: 1)
            } else if count <= 8 {
                let red     = CGFloat((Int64(value) & 0xFF000000) >> 24) / divisor
                let green   = CGFloat((Int64(value) & 0x00FF0000) >> 16) / divisor
                let blue    = CGFloat((Int64(value) & 0x0000FF00) >>  8) / divisor
                let alpha   = CGFloat( Int64(value) & 0x000000FF       ) / divisor
                return .init(red: red, green: green, blue: blue, alpha: alpha)
            } else {
                assertionFailure("StemColor: 位数错误, 只支持 6 或 8 位, count: \\(count)")
            }

            return .black
        }

        init(light hex1: Int64, dark hex2: Int64) {
            self.hex1 = hex1
            self.hex2 = hex2
        }

    }

    public class Data: Base {

        public var data: Foundation.Data {
            if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .data)) {
                return asset.data
            } else if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .none)) {
                return asset.data
            } else if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .main)) {
                return asset.data
            } else {
                assert(false, "未查询到相应资源")
                return Foundation.Data()
            }
        }

    }

    public class GIF: AssetSource.Data {

        public override var data: Foundation.Data {
            if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .gif)) {
                return asset.data
            } else if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .none)) {
                return asset.data
            } else if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .main)) {
                return asset.data
            } else {
                assert(false, "未查询到相应资源")
                return Foundation.Data()
            }
        }

    }

    public class Image: Base {

        public var image: UIImage {
            if let image = UIImage(named: name, in: RBundle.bundle(for: .image), compatibleWith: nil) {
                return image
            } else if let image = UIImage(named: name, in: RBundle.bundle(for: .none), compatibleWith: nil) {
                return image
            } else if let image = UIImage(named: name, in: RBundle.bundle(for: .main), compatibleWith: nil) {
                return image
            } else {
                assert(false, "未查询到相应资源")
                return UIImage()
            }
        }

    }

}

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
        return .init(template: JSON(["text": text,
                                     "gif_code": gif_code,
                                     "image_code": image_code,
                                     "color_code": color_code]))
    }()
    
}
