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

    enum Mode: String {
        case tag
        case branch
    }

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

    var templateModel: TemplateModel
    let repo: Repo?

    init?(json: JSON) {
        guard let templateModel = TemplateModel(json: json) else {
            return nil
        }
        self.templateModel = templateModel
        repo = Repo(json: json["repo"])
    }
}
