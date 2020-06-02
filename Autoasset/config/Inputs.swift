//
//  Inputs.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/29.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Inputs {
    let inputs: [URL]

    init?(json: JSON) {
        let inputs = json["inputs"].arrayValue.compactMap({ $0.fileURL })
        guard inputs.isEmpty == false else {
            return nil
        }
        self.inputs = inputs
    }

    init(inputs json: JSON) {
        inputs = json["inputs"].arrayValue.compactMap({ $0.fileURL })
    }
}
