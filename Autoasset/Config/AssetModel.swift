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

    class Inputs {
        let inputs: [URL]

        init?(json: JSON) {
            let inputs = json["inputs"].arrayValue.compactMap({ $0.fileURL })
            guard inputs.isEmpty == false else {
                return nil
            }
            self.inputs = inputs
        }

        init(inputs json: JSON) {
            inputs = json["inputs"].arrayValue.compactMap({ $0.fileURL })
        }
    }

    class Resource: Inputs {

        let output: URL

        override init?(json: JSON) {
            guard let output = json["output"].fileURL else {
                return nil
            }
            self.output = output

            super.init(json: json)
        }
    }

    class Xcasset: Resource {

        let contents: Inputs

        override init?(json: JSON) {
            self.contents = Inputs(inputs: json["contents"])
            super.init(json: json)
        }

    }

    let template: Template?

    var images: Xcasset?
    var gifs: Xcasset?
    var datas: Xcasset?
    var colors: Xcasset?
    var fonts: Resource?
    var clear: Inputs?

    init(json: JSON) {
        images = Xcasset(json: json["images"])
        datas = Xcasset(json: json["datas"])
        gifs = Xcasset(json: json["gifs"])
        colors = Xcasset(json: json["colors"])
        fonts = Resource(json: json["fonts"])
        clear = Inputs(json: json["clear"])
        template = Template(json: json["template"], default: ASTemplate.asset)
    }

}
