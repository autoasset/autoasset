//
//  PodspecModel.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

struct PodspecModel: TemplateModelProtocol {

    struct Repo {
        let name: String
        let url: String
        init?(json: JSON) {
            guard let name = json["name"].string, let url = json["url"].string else {
                return nil
            }
            self.name = name
            self.url = url
        }
    }

    enum Attribute: String {
        case verbose        = "--verbose"
        case no_clean       = "--no-clean"
        case allow_warnings = "--allow-warnings"
    }

    /// 附加属性
    private(set) var attributes = [Attribute]()

    var templateModel: TemplateModel
    let repo: Repo?

    init?(json: JSON) {
        guard let templateModel = TemplateModel(json: json["template"]) else {
            return nil
        }
        self.templateModel = templateModel
        repo = Repo(json: json["repo"])

        let attributesJSON = json["attributes"]
        if attributesJSON["allow_warnings"].boolValue {
            attributes.append(.allow_warnings)
        }

        if attributesJSON["no_clean"].boolValue {
            attributes.append(.no_clean)
        }

        if attributesJSON["verbose"].boolValue {
            attributes.append(.verbose)
        }
    }
}
