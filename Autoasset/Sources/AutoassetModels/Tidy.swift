// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
