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
    let base: URL?

    init?(json: JSON, base: URL) {
        self.base = base
        guard json["inputs"].arrayValue.isEmpty == false else {
            return nil
        }

        inputs = json["inputs"]
            .arrayValue
            .compactMap({ $0.string })
            .map({ item -> URL in
                if ["file://", "~/"].contains(where: { item.hasPrefix($0) }) {
                    return URL(string: item)!.standardized
                } else {
                    return base.appendingPathComponent(item).standardized
                }
            })
    }

    init(inputs json: JSON, base: URL? = nil) {
        self.base = base
        if let base = base {
            inputs = json
                .arrayValue
                .compactMap({ $0.string })
                .map({ base.appendingPathComponent($0) })
        } else {
            inputs = json.arrayValue.compactMap({ $0.fileURL })
        }
    }

}
