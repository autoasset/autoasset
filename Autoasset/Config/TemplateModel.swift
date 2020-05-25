//
//  TemplateModel.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class TemplateModel: TemplateProtocol {

    var text: String
    var output: URL

    init?(json: JSON) {
        guard let output = Self.load(output: json) else {
            return nil
        }

        guard let text = Self.load(input: json) else {
            return nil
        }

        self.text = text
        self.output = output
    }

}


protocol TemplateModelProtocol {
    var templateModel: TemplateModel { get }
}

extension TemplateModelProtocol {
    var text: String { templateModel.text }
    var output: URL { templateModel.output }
}
