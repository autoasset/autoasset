//
//  AssetCode.swift
//  Autoasset
//
//  Created by 林翰 on 2020/7/10.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

struct AssetCode {
    
    struct Color {
        let light: String
        let dark: String
        let mark: String
    }
    
    let color: Color
    let variableName: String
    let xcassetName: String

    init(variableName: String, xcassetName: String) {
        self.variableName = variableName
        self.xcassetName = xcassetName
        self.color = Color(light: "", dark: "", mark: "")
    }

    init(variableName: String, xcassetName: String, color: Color) {
        self.variableName = variableName
        self.xcassetName = xcassetName
        self.color = color
    }

}
