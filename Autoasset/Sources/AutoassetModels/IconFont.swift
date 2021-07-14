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
    
    public enum TemplateType {
        case flutter(FlutterTemplate)
    }
    
    public struct FlutterTemplate {
        public let output: String
        public let className: String
        public let fontFamily: String
        public let fontPackage: String
    }
    
    public struct Font {
        public let output: String
        public let fontType: FontType
    }
    
    public let package: String
    public let font: Font
    public let template: TemplateType

    init?(from json: JSON) {
        guard let package = json["package"].string else { return nil }
        self.package = package
        
        let font = json["font"]
        guard font.exists(), let output = font["output"].string else { return nil }
        
        self.font = .init(output: output,
                          fontType: FontType(rawValue: font["type"].stringValue) ?? .ttf)
        
        
        if json["flutter"].exists() {
            let template = json["flutter"]
            guard let output = template["output"].string else { return nil }
            let fontFamily = template["font_family"].string ?? "IconFont"
            self.template = .flutter(.init(output: output,
                                           className: template["class_name"].string ?? fontFamily,
                                           fontFamily: fontFamily,
                                           fontPackage: template["font_package"].string ?? fontFamily))
        } else {
            return nil
        }
    }
    
}
