//
//  File.swift
//  
//
//  Created by linhey on 2021/8/9.
//

import StemCrossPlatform

struct Color: Hashable {
    let light: StemColor
    let dark: StemColor
    
    init?(json: JSON) {
        self.light = StemColor(hex: json["light"].string ?? json["any"].stringValue)
        self.dark  = StemColor(hex: json["dark"].string ?? json["any"].stringValue)
    }
}
