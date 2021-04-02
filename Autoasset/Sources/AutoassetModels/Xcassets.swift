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
        
        public init?(output: String?) {
            guard let output = output else {
                return nil
            }
            self.output = output
        }
        
        public init(output: String) {
            self.output = output
        }
        
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
        
        public init(inputs: [String], output: String) {
            self.inputs = inputs
            self.output = output
        }
        
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
        
        public init(inputs: [String],
                    output: String,
                    space: String?) {
            self.space = space
            super.init(inputs: inputs, output: output)
        }
        
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
        
        public init(inputs: [String],
                    output: String,
                    report: String?,
                    prefix: String,
                    contents: String?,
                    bundle_name: String?) {
            self.report = report
            self.prefix = prefix
            self.contents = contents
            self.bundle_name = bundle_name
            super.init(inputs: inputs, output: output)
        }
        
        override init?(from json: JSON) {
            contents = json["contents"].string
            report = json["report"].string
            bundle_name = json["bundle_name"].string
            prefix = json["prefix"].stringValue
            super.init(from: json)
        }
        
    }
    
    public typealias Data = Image
    
    public let colors: [Color]
    public let images: [Image]
    public let gifs: [Data]
    public let datas: [Data]
    public let template: Template?
    
    public init(colors: [Color],
                images: [Image],
                gifs: [Data],
                datas: [Data],
                template: Template?) {
        self.colors = colors
        self.images = images
        self.gifs = gifs
        self.datas = datas
        self.template = template
    }
    
    init(from json: JSON) {
        colors = json["colors"].arrayValue.compactMap(Color.init(from:))
        images = json["images"].arrayValue.compactMap(Image.init(from:))
        gifs  = json["gifs"].arrayValue.compactMap(Data.init(from:))
        datas = json["datas"].arrayValue.compactMap(Data.init(from:))
        template = Template(from: json["template"])
    }
    
}
