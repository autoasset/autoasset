//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import StemCrossPlatform

public struct Download {
    
    public struct Git {
        
        public let input: String
        public let output: String
        public let branch: String
        
        init?(from json: JSON) {
            self.output = json["output"].stringValue
            self.input = json["input"].stringValue
            self.branch = json["branch"].stringValue
            guard output.isEmpty == false,
                  input.isEmpty == false,
                  branch.isEmpty == false else {
                return nil
            }
        }
    }
    
    public let gits: [Git]
    
    init(from json: JSON) {
        self.gits = json["gits"].arrayValue.compactMap(Git.init(from:))
    }
    
}
