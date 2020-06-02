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
    let inputs: [String]

    init(json: JSON) {
        inputs = json["inputs"].arrayValue.map({ $0.stringValue })
    }
}
