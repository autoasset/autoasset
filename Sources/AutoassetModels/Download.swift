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
import Stem

public struct Download {
    
    public struct Git {
        public let name: String
        public let input: String
        public let output: String
        public let branch: String
        
        public init(name: String,
                    input: String,
                    output: String,
                    branch: String) {
            self.name   = name
            self.input  = input
            self.output = output
            self.branch = branch
        }
        
        init?(from json: JSON) {
            self.name   = json["name"].stringValue
            self.output = json["output"].stringValue
            self.input  = json["input"].stringValue
            self.branch = json["branch"].stringValue
            guard name.isEmpty == false,
                  output.isEmpty == false,
                  input.isEmpty == false,
                  branch.isEmpty == false else {
                return nil
            }
        }
    }
    
    public let gits: [Git]
    
    public init(gits: [Git]) {
        self.gits = gits
    }
    
    init(from json: JSON) {
        self.gits = json["gits"].arrayValue.compactMap(Git.init(from:))
    }
    
}
