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

    struct Clone {
        let url: String
        let branchs: [String]
        static let output: String = "git-inputs/"

        init(url: String?, branchs: [String]) throws {
            if let url = url {
                self.url = url
            } else {
                self.url = try Git().info.url()
            }

            if branchs.isEmpty {
                self.branchs = ["master"]
            } else {
                self.branchs = branchs
            }
        }

        func folder(for branch: String) -> String {
            let spec = url.split(separator: "/").last?.split(separator: ".").first?.description ?? ""
            return Clone.output + spec + "/" + branch
        }
        
    }

    let inputs: [Clone]

    init(json: JSON) throws {
        inputs = try json["inputs"].arrayValue.map({
            try Clone(url: $0["url"].string, branchs: $0["branchs"].arrayValue.compactMap({ $0.string }))
        })
    }
}
