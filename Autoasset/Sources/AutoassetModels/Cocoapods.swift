//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import StemCrossPlatform

public struct Cocoapods {
    
    public enum Trunk {
        case github
        case git(url: String)
        
        init?(from json: JSON) {
            if json["isGithub"].boolValue {
                self = .github
            } else if let repo = json["repo"].string,
                      repo.isEmpty == false {
                self = .git(url: repo)
            } else {
                return nil
            }
        }
    }
    
    public struct Podspec {
        public let text: String
        public let output: String
        
        init?(from json: JSON) {
            text = json["text"].stringValue
            output = json["output"].stringValue
            guard output.isEmpty == false else {
                return nil
            }
        }
    }
    
    public let trunk: Trunk?
    public let podspec: Podspec?
    
    init?(from json: JSON) {
        trunk = Trunk(from: json["trunk"])
        podspec = Podspec(from: json["podspec"])
        
        if trunk == nil, podspec == nil {
            return nil
        }
    }
    
}
