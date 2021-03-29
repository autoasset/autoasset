//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

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
