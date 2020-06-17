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
        let gif_code   = "    static var [variable_name]: AssetSource.GIF { AssetSource.GIF(asset: \"[name]\") }"
        let image_code = "    static var [variable_name]: AssetSource.Image { AssetSource.Image(asset: \"[name]\") }"
        let text = """
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
import Foundation

fileprivate class RBundle {

    enum `Type` {
        case image
        case gif
        case data
        case color

        var name: String {
            switch self {
            case .image: return "[image_bundle_name]"
            case .gif:   return "[gif_bundle_name]"
            case .data:  return "[data_bundle_name]"
            case .color: return "[color_bundle_name]"
            }
        }

    }

  static func bundle(for type: `Type`) -> Bundle {
        guard let url = Bundle(for: RBundle.self).url(forResource: type.name, withExtension: "bundle"), let bundle = Bundle(url: url) else {
                assert(false, "未查询到相应资源")
                return .main
        }

        return bundle
    }
}

public class AssetSource {

    public class Base {
        public let name: String
        init(asset named: String) {
            self.name = named
        }
    }

    public class Data: Base {
        public var data: Foundation.Data {
            if let asset = NSDataAsset(name: name, bundle: RBundle.bundle(for: .data)) {
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
            } else {
                assert(false, "未查询到相应资源")
                return UIImage()
            }
        }
    }

}

public enum R {
    public static let images = Image.self
    public static let gifs   = GIF.self
    static let colors = Color.self
    static let datas  = Data.self

    public enum Image { }
    public enum GIF { }
    enum Color { }
    enum Data { }
}

public typealias Asset = R.Image

public extension R.Image {
[images_code]
}

public extension R.GIF {
[gifs_code]
}

extension R.Color {
[colors_code]
}

extension R.Data {
[datas_code]
}

"""
        return .init(template: JSON(["text": text, "gif_code": gif_code, "image_code": image_code]))
    }()
    
}
