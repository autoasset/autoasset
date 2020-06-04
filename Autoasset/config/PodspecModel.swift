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

    var templateModel: TemplateModel
    let repo: Repo?
    let noClean: Bool
    let allowWarnings: Bool
    let verbose: Bool

    init?(json: JSON) {
        guard let templateModel = TemplateModel(json: json["template"]) else {
            return nil
        }
        self.templateModel = templateModel
        repo = Repo(json: json["repo"])
        noClean = json["no_clean"].bool ?? true
        allowWarnings = json["allow_warnings"].bool ?? true
        verbose = json["verbose"].bool ?? true
    }
}
