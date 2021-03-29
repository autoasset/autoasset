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

public struct Xcassets {
    
    public class Template {
        
        public let output: String
        
        init?(from json: JSON) {
            output = json["output"].stringValue
            if output.isEmpty {
                return nil
            }
        }
    }
    
    public class Resource {
        public let inputs: [String]
        public let output: String
        
        init?(from json: JSON) {
            inputs = json["inputs"].arrayValue.compactMap(\.string)
            output = json["output"].stringValue
            if inputs.isEmpty || output.isEmpty {
                return nil
            }
        }
    }
    
    public class Color: Resource {
        public let space: String?
        override init?(from json: JSON) {
            space = json["space"].string
            super.init(from: json)
        }
    }
    
    public class Image: Resource {
        
        public let report: String?
        public let prefix: String
        public let contents: String?
        public let bundle_name: String?
        
        override init?(from json: JSON) {
            contents = json["contents"].string
            report = json["report"].string
            bundle_name = json["bundle_name"].string
            prefix = json["prefix"].stringValue
            super.init(from: json)
        }
        
    }
    
    public class Data: Resource {
        
        public let report: String?
        public let prefix: String
        public let contents: String?
        public let bundle_name: String?
        
        override init?(from json: JSON) {
            contents = json["contents"].string
            report = json["report"].string
            bundle_name = json["bundle_name"].string
            prefix = json["prefix"].stringValue
            super.init(from: json)
        }
        
    }
    
    public let colors: [Color]
    public let images: [Image]
    public let gifs: [Data]
    public let datas: [Data]
    public let template: Template?

    init(from json: JSON) {
        colors = json["colors"].arrayValue.compactMap(Color.init(from:))
        images = json["images"].arrayValue.compactMap(Image.init(from:))
        gifs  = json["gifs"].arrayValue.compactMap(Data.init(from:))
        datas = json["datas"].arrayValue.compactMap(Data.init(from:))
        template = Template(from: json["template"])
    }
    
}
