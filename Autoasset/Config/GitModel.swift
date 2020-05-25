//
//  GitModel.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

struct GitModel {
    let pushURL: String?
    let projectPath: String
    let branchs: [String]

    init(json: JSON) {
        branchs = json["branchs"].arrayValue.map({ $0.stringValue })
        pushURL = json["push_url"].string
        projectPath = json["project_path"].string ?? "../"
    }
}
