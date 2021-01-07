//
//  AssetCode.swift
//  Autoasset
//
//  Created by 林翰 on 2020/7/10.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

struct AssetCode {
    
    struct Color {
        let light: String
        let dark: String
        let mark: String
    }
    
    struct Input {
        let filePaths: [FilePath]
    }
    
    struct Output {
        /// 变量名
        let variableName: String
        /// asset 文件夹
        let folder: FilePath
        /// 颜色
        let color: Color?
    }
    
    let input: Input
    let output: Output

    init(input: Input, output: Output) {
        self.input = input
        self.output = output
    }

}
