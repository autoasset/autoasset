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
        case test_config
        case normal_without_git_push
    }

    struct Variables {
        let version: String
        
        /// 组成版本号的数字从git分支名中提取
        /// The numbers that make up the version number are extracted from the git branch name
        let enableAutomaticVersionNumberGeneration: Bool
        
        init(version: String) {
            self.version = version
            enableAutomaticVersionNumberGeneration = true
        }

        init(json: JSON) {
            version = json["version"].stringValue
            enableAutomaticVersionNumberGeneration = json["enable_automatic_version_number_generation"].bool ?? true
        }
    }
    
    let types: [Style]
    let variables: Variables

    static let `default` = ModeModel(type: .normal, variables: .init(version: "0"))

    init(type: Style, variables: Variables) {
        self.types = [type]
        self.variables = variables
    }

    init(json: JSON) {
        let type = Style(rawValue: json["type"].stringValue) ?? .normal
        let types = json["types"].arrayValue.compactMap({ Style(rawValue: $0.stringValue) })
        self.types = types.isEmpty ? [type] : types
        variables = Variables(json: json["variables"])
    }

}


