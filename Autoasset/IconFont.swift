//
//  IconFont.swift
//  Autoasset
//
//  Created by 林翰 on 2020/5/19.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class IconFont {

    let font: CTFont

    init?(from url: URL) {
        guard let font = CTFont.st.load(from: url) else {
            return nil
        }
        self.font = font
    }

}
