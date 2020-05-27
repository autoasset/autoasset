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

    class Resource {
        let inputs: [URL]
        let output: URL

        init?(json: JSON) {
            inputs = json["inputs"].arrayValue.compactMap({ $0.fileURL })
            guard inputs.isEmpty == false, let output = json["output"].fileURL else {
                return nil
            }
            self.output = output
        }

    }

    class Xcasset: Resource {

        let contentsPath: URL?

        override init?(json: JSON) {
            contentsPath = json["contents_path"].fileURL
            super.init(json: json)
        }

    }

    let template: Template?

    var images: Xcasset?
    var gifs: Xcasset?
    var datas: Xcasset?
    var colors: Xcasset?
    var fonts: Resource?

    init(json: JSON) {
        images = Xcasset(json: json["images"])
        datas = Xcasset(json: json["datas"])
        gifs = Xcasset(json: json["gifs"])
        colors = Xcasset(json: json["colors"])
        fonts = Resource(json: json["fonts"])
        template = Template(json: json["template"], default: ASTemplate.asset)
    }

}
