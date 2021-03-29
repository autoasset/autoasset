//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import StemCrossPlatform

public struct PlaceHolder {
    
    public let version: String
    
    public init(version: String) {
        self.version = version
    }
    
}

public struct Variables {
    
    public enum Version {
        /// 当前分支名中提取版本号
        case fromGitBranch
        /// 寻找下个Tag
        case nextGitTag
        /// 自定义
        case text(String)
        
        init(from json: JSON) {
            if let text = json["text"].string {
                self = .text(text)
            } else if json["nextGitTag"].boolValue {
                self = .nextGitTag
            } else if json["fromGitBranch"].boolValue {
                self = .fromGitBranch
            } else {
                self = .text("0")
            }
        }
    }
    
    public let version: Version
    
    init(from json: JSON) {
        version = Version(from: json["version"])
    }
    
}
