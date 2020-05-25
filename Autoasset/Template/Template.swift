//
//  Template.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/24.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Yams
import Stem

class ASTemplate { }

// MARK: - asset
extension ASTemplate {

    static let asset: AssetModel.Template = {
        let text = try! String(contentsOfFile: Bundle.main.path(forResource: "asset", ofType: "txt")!)
        let yml = try! Yams.load(yaml: text)!
        return .init(template: JSON(yml))
    }()
    
}
