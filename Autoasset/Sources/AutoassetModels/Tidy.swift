//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import StemCrossPlatform

public struct Tidy {
    
    public class Copy {
        public let name: String
        public let inputs: [String]
        public let output: String
        
        init?(from json: JSON) {
            name = json["name"].stringValue
            inputs = json["inputs"].arrayValue.compactMap(\.string)
            output = json["output"].stringValue
            guard name.isEmpty == false,
                  output.isEmpty == false else {
                return nil
            }
        }
    }
    
    public enum CreateInput {
        case text(String)
        case input(String)
    }
    
    
    public class Create {
        public let name: String
        public let type: CreateInput

        init?(from json: JSON) {
            name = json["name"].stringValue
            
            if let item = json["text"].string, item.isEmpty == false {
                type = .text(item)
            } else if let item = json["input"].string, item.isEmpty == false {
                type = .input(item)
            } else {
                return nil
            }
                        
            guard name.isEmpty == false else {
                return nil
            }
        }
    }
    
    public class Clear {
        public let name: String
        public let inputs: [String]
        
        init?(from json: JSON) {
            name = json["name"].stringValue
            inputs = json["inputs"].arrayValue.compactMap(\.string)
            guard name.isEmpty == false else {
                return nil
            }
        }
    }
    
    public let clears: [Clear]
    public let copies: [Copy]
    public let create: [Create]

    init(from json: JSON) {
        clears = json["clears"].arrayValue.compactMap(Clear.init(from:))
        copies = json["copies"].arrayValue.compactMap(Copy.init(from:))
        create = json["create"].arrayValue.compactMap(Create.init(from:))
    }
    
}
