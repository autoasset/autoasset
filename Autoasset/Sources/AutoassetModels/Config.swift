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

public struct Config {
    
    public class Children {
        public let name: String
        public let inputs: [String]
        public let variables: Variables
        
        public init(name: String, inputs: [String], variables: Variables) {
            self.name = name
            self.inputs = inputs
            self.variables = variables
        }
        
        init?(from json: JSON) {
            name = json["name"].stringValue
            variables = Variables(from: json["variables"])
            inputs = json["inputs"].arrayValue.compactMap(\.string)
            guard name.isEmpty == false else {
                return nil
            }
        }
    }
    
    public let configs: [Children]
    public let modes: [Mode]
    public var debug: Debug?
    public let cocoapods: Cocoapods?
    public let xcassets: Xcassets
    public let download: Download?
    public let tidy: Tidy
    public var variables: Variables
    public var iconfonts: [IconFont]

    
    public init(from json: JSON) {
        configs = json["configs"].arrayValue.compactMap(Children.init(from:))
        modes = json["modes"].arrayValue.compactMap(Mode.init(from:))
        debug = Debug(from: json["debug"])
        cocoapods = Cocoapods(from: json["cocoapods"])
        xcassets = Xcassets(from: json["xcassets"])
        download = Download(from: json["download"])
        tidy = Tidy(from: json["tidy"])
        variables = Variables(from: json["variables"])
        iconfonts = json["iconfonts"].arrayValue.compactMap(IconFont.init(from:))
    }
    
}
