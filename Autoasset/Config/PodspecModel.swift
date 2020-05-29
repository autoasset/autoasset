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
    let type: Mode

    init?(json: JSON) {
        guard let templateModel = TemplateModel(json: json["template"]) else {
            return nil
        }
        self.templateModel = templateModel
        type = Mode(rawValue: json["type"].stringValue) ?? .tag

        switch type {
        case .branch:
            repo = nil
        case .tag:
            repo = Repo(json: json["repo"])
        }
    }
}
