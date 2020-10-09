//
//  TemplateProtocol.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem
import Yams

protocol TemplateInputProtocol {
    var text: String { get set }
}

extension TemplateInputProtocol {

   static func load(input json: JSON) -> String? {
        if let text = json["text"].string {
            return text
        }

        guard let path = json["input"].url?.path ?? json["path"].url?.path,
              let text = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        return text.isEmpty ? nil : text
    }

}

protocol TemplateOutputProtocol {
    var output: URL { get set }
}

extension TemplateOutputProtocol {

   static func load(output json: JSON) -> URL? {
        guard let output = json["output"].string else {
            return nil
        }
        return Env.rootURL.appendingPathComponent(output)
    }

}

typealias TemplateProtocol = TemplateInputProtocol & TemplateOutputProtocol


