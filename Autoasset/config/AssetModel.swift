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
            return URL(string: value)?.standardized
        }

        return try? FilePath(path: value, type: .file).url
    }
}

struct AssetModel {

    class Template: TemplateProtocol {
        var core: String
        var text: String
        var output: URL
        let gifCode: String
        let imageCode: String
        let colorCode: String

        init(template json: JSON) {
            self.core      = json["core"].stringValue
            self.text      = json["text"].stringValue
            self.output    = URL(stringLiteral: "./")
            self.gifCode   = json["gif_code"].stringValue
            self.imageCode = json["image_code"].stringValue
            self.colorCode = json["color_code"].stringValue
        }

        init?(json: JSON, default model: Template) {
            guard let output = Self.load(output: json) else {
                return nil
            }

            self.output = output
            self.text = Self.load(input: json) ?? model.text
            self.core = json["core"].string ?? model.core

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

            if let code = json["color_code"].string, code.isEmpty == false {
                self.colorCode = code
            } else {
                self.colorCode = model.colorCode
            }
        }

    }

    class Resource: Inputs {

        let output: URL

        override init?(json: JSON, base: URL) {
            guard let output = json["output"].string else {
                return nil
            }

            self.output = Env.rootURL.appendingPathComponent(output)
            super.init(json: json, base: base)
        }

    }

    class Xcasset: Resource {

        let contents: Inputs
        fileprivate(set) var prefix: String
        fileprivate(set) var variablePrefix: String
        let bundleName: String?
        let report: String?

        override init?(json: JSON, base: URL) {
            self.bundleName = json["bundle_name"].string
            self.report     = json["report"].string
            self.prefix     = json["prefix"].stringValue
            self.contents   = Inputs(inputs: json["contents"], base: base)
            self.variablePrefix = json["variable_prefix"].stringValue
            super.init(json: json, base: base)
        }

    }

    class ColorXcasset: Xcasset {

        let space: String

        override init?(json: JSON, base: URL) {
            space = json["space"].string ?? "display-p3"
            super.init(json: json, base: base)
            self.variablePrefix = self.variablePrefix.isEmpty ? "_" : self.variablePrefix
        }

    }

    let template: Template?

    var clear: Inputs?
    var xcassets: Resource?
    var codes: Resource?

    var images: Xcasset?
    var gifs: Xcasset?
    var datas: Xcasset?
    var colors: Xcasset?
    var fonts: Resource?
    var base: URL?

    init(json: JSON, base: URL) {
        self.base = base
        images = Xcasset(json: json["images"], base: base)
        datas  = Xcasset(json: json["datas"], base: base)
        gifs   = Xcasset(json: json["gifs"], base: base)
        colors = ColorXcasset(json: json["colors"], base: base)
        fonts  = Resource(json: json["fonts"], base: base)
        clear  = Inputs(json: json["clear"], base: base)
        codes  = Resource(json: json["codes"], base: base)
        xcassets = Resource(json: json["xcassets"], base: base)
        template = Template(json: json["template"], default: ASTemplate.asset)
    }


}
