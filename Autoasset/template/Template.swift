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
        let gif_code   = "    static var [variable_name]: AssetSource.Data { AssetSource.Data(asset: \"[name]\") }"
        let image_code = "    static var [variable_name]: AssetSource.Image { AssetSource.Image(asset: \"[name]\") }"
        let text = """
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Foundation

fileprivate class RBundle {
    static let bundle = Bundle(path: Bundle(for: RBundle.self).resourcePath!.appending("/Resources.bundle"))!
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

public class AssetSource {

    public class Base {
        public let name: String
        init(asset named: String) {
            self.name = named
        }
    }

    public class Data: Base {
        public var data: Foundation.Data {
            if let asset = NSDataAsset(name: name, bundle: RBundle.bundle) {
                return asset.data
            } else {
                assert(false, "未查询到相应资源")
                return Foundation.Data()
            }
        }
    }

    public class Image: Base {
        public var image: UIImage {
            if let image = UIImage(named: name, in: RBundle.bundle, compatibleWith: nil) {
                return image
            } else {
                assert(false, "未查询到相应资源")
                return UIImage()
            }
        }
    }

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
