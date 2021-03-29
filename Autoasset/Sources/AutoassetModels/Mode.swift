//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

import Foundation
import StemCrossPlatform

public enum Mode {
    
    case download
    case tidy(name: String)
    case xcassets
    case cocoapods
    
    init?(from json: JSON) {
        if let tidy = json["tidy"].string {
            self = .tidy(name: tidy)
        } else {
            switch json.stringValue {
            case "download": self = .download
            case "xcassets": self = .xcassets
            case "cocoapods": self = .cocoapods
            default:
                return nil
            }
        }
    }
    
}
