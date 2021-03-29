//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

import Foundation
import StemCrossPlatform

public struct Environment {
    
    public let version: String?
    /// 组成版本号的数字从git分支名中提取 | defalut: true
    /// The numbers that make up the version number are extracted from the git branch name
    public let enable_automatic_version_number_generation: Bool
    
    init(from json: JSON) {
        version = json["version"].string
        enable_automatic_version_number_generation = json["enable_automatic_version_number_generation"].bool ?? true
    }
    
}
