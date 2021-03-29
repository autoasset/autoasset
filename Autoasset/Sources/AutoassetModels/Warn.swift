//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

import Foundation
import StemCrossPlatform

public struct Warn {
    
    public let output: String
    
    init?(from json: JSON) {
        
        if let value = json["output"].string {
            output = value
        } else {
            return nil
        }
        
    }
}
