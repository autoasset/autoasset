//
//  AssetModel.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

extension JSON {
    var fileURL: URL? {
        guard let value = string else {
            return nil
        }

        if ["file://", "~/"].contains(where: { value.hasPrefix($0) }) {
            return URL(string: value)
        }

        return try? FilePath(path: value, type: .file).url
    }
}

struct AssetModel {

    class Template: TemplateProtocol {
        var text: String
        var output: URL
        let gifCode: String
        let imageCode: String

        init(template json: JSON) {
            self.text = json["text"].stringValue
            self.output = URL(stringLiteral: "./")
            self.gifCode = json["gif_code"].stringValue
            self.imageCode = json["image_code"].stringValue
        }

        init?(json: JSON, default model: Template) {
            guard let output = Self.load(output: json) else {
                return nil
            }

            self.output = output
            self.text = Self.load(input: json) ?? model.text

            if let code = json["gif_code"].string, code.isEmpty == false {
                self.gifCode = code
            } else {
                self.gifCode = model.gifCode
            }

            if let code = json["image_code"].string, code.isEmpty == false {
                self.imageCode = code
            } else {
                self.imageCode = model.imageCode
            }
        }

    }

    class Resource: Inputs {

        let output: URL

        override init?(json: JSON, base: URL? = nil) {
            guard let output = json["output"].fileURL else {
                return nil
            }
            self.output = output
            super.init(json: json, base: base)
        }

    }

    class Xcasset: Resource {

        let contents: Inputs
        let prefix: String
        let bundleName: String?

        override init?(json: JSON, base: URL? = nil) {
            self.bundleName = json["bundle_name"].string
            self.prefix     = json["prefix"].stringValue
            self.contents   = Inputs(inputs: json["contents"], base: base)
            super.init(json: json, base: base)
        }

    }

    let template: Template?

    var images: Xcasset?
    var gifs: Xcasset?
    var datas: Xcasset?
    var colors: Xcasset?
    var fonts: Resource?
    var clear: Inputs?
    var base: URL?

    init(json: JSON, base: URL?) {
        self.base = base
        images = Xcasset(json: json["images"], base: base)
        datas = Xcasset(json: json["datas"], base: base)
        gifs = Xcasset(json: json["gifs"], base: base)
        colors = Xcasset(json: json["colors"], base: base)
        fonts = Resource(json: json["fonts"], base: base)
        clear = Inputs(json: json["clear"])
        template = Template(json: json["template"], default: ASTemplate.asset)
    }


}
