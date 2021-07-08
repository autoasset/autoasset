//
//  File.swift
//  
//
//  Created by linhey on 2021/7/8.
//

import Foundation
import StemCrossPlatform

public struct IconFont {
    
    public struct Model {
        
        public struct Glyph {
            
            public let ID: String
            public let name: String
            public let fontClass: String
            public let unicode: String
            public let unicodeDecimal: Int
            
            init?(from json: JSON) {
                self.ID = json["icon_id"].stringValue
                self.name = json["name"].stringValue
                self.fontClass = json["font_class"].stringValue
                self.unicode = json["unicode"].stringValue
                self.unicodeDecimal = json["unicode_decimal"].intValue
                guard self.unicode.isEmpty == false else {
                    return nil
                }
            }
        }
        
        public let ID: String
        public let name: String
        public let fontFamily: String
        public let description: String
        public let glyphs: [Glyph]
        
        public init(from json: JSON) {
            self.ID = json["id"].stringValue
            self.name = json["name"].stringValue
            self.fontFamily = json["font_family"].stringValue
            self.description = json["description"].stringValue
            self.glyphs = json["glyphs"].arrayValue.compactMap(Glyph.init(from:))
        }
        
    }
    
    public enum FontType: String {
        case ttf
        case woff
        case woff2
    }
    
    public enum TemplateType: String {
        case swift
        case flutter
    }
    
    public struct Template {
        public let output: String
        public let type: TemplateType
    }
    
    public let input: String
    public let fontType: FontType
    public let template: Template
    
    init?(from json: JSON) {
        guard let input = json["input"].string,
              let output = json["template"]["output"].string,
              let templateType = TemplateType(rawValue: json["template"]["type"].stringValue) else {
            return nil
        }
        self.input = input
        self.fontType = FontType(rawValue: json["font_type"].stringValue) ?? .ttf
        self.template = .init(output: output, type: templateType)
    }
    
}
