//
//  Mode.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class ModeModel {

    enum Style: String {
        case normal
        case local
        case pod_with_branch
        case test_message
        case test_podspec
        case test_warn
    }

    struct Variables {
        let version: String

        init(version: String) {
            self.version = version
        }

        init(json: JSON) {
            version = json["version"].stringValue
        }
    }
    
    let type: Style
    let variables: Variables

    static let `default` = ModeModel(type: .normal, variables: .init(version: "0"))

    init(type: Style, variables: Variables) {
        self.type = type
        self.variables = variables
    }

    init(json: JSON) {
        type = Style(rawValue: json["type"].stringValue) ?? .normal
        variables = Variables(json: json["variables"])
    }

}


