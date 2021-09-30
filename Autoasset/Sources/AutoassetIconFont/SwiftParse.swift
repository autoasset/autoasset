//
//  File.swift
//  
//
//  Created by linhey on 2021/9/29.
//

import Foundation
import AutoassetModels
import StemCrossPlatform
import VariablesMaker

struct SwiftParse {
    
    let model: IconFont.Model
    let template: IconFont.iOSTemplate
    
    let folder: FilePath.Folder
    let variablesMaker: VariablesMaker
    
    func createDefaultFiles() throws {
        try folder.create(file: "autoasset_iconfont_protocol.swift", data: template_protocol().data(using: .utf8))
        try folder.create(file: "autoasset_iconfont.swift", data: template_core().data(using: .utf8))
    }
    
    func createListFile() throws {
        let list = try model.glyphs.map { glyph in
            return [
                #"   static var "#,
                NameFormatter().variable(glyph.name),
                #": Self { .init(code: "\u{"#,
                glyph.unicode,
                #"}", in: ""#,
                try variablesMaker.textMaker(template.bundle),
                #"", familyName: ""#,
                model.fontFamily,
                #"", dataName: ""#,
                try variablesMaker.textMaker(template.prefix) + model.fontFamily,
                #"") }"#
            ].joined()
        }.joined(separator: "\n")
        
        let header =
        #"""
        #if canImport(AppKit)
        import AppKit
        #elseif canImport(UIKit)
        import UIKit
        #endif
        """#
        
        let str = header + "\n" + "public extension AutoAssetIconFontProtocol {\n\(list)\n}"
        try folder.create(file: "autoasset_iconfont_list.swift", data: str.data(using: .utf8))
    }
    
}

private extension SwiftParse {
    
    func listFileName(_ string: String) -> String {
        guard folder.file(name: string + ".swift").isExist else {
            return string + ".swift"
        }
        return listFileName(string + "_EX")
    }
    
}

private extension SwiftParse {
    
    func template_protocol() -> String {
        #"""
        #if canImport(AppKit)
        import AppKit
        #elseif canImport(UIKit)
        import UIKit
        #endif
        
        public protocol AutoAssetIconFontProtocol {
            init(code: String, in bundle: String, familyName: String, dataName: String)
        }
        """#
    }
    
    func template_core() -> String {
        #"""
        #if canImport(AppKit)
        import AppKit
        #elseif canImport(UIKit)
        import UIKit
        #endif

        public class AutoAssetIconFont: AutoAssetIconFontProtocol {

            let code: String
            let bundle: String
            let familyName: String
            let dataName: String
            
            private static var registerMap = [String: Bool]()
            
            required public init(code: String, in bundle: String, familyName: String, dataName: String) {
                self.code = code
                self.bundle = bundle
                self.familyName = familyName
                self.dataName = dataName
            }
            
        }

        public extension AutoAssetIconFont {

            var string: String {
                if Self.registerMap[familyName] == true {
                    return code
                }
                
                if isAvailable(familyName: familyName) == false {
                    try? register(data: data())
                    Self.registerMap[familyName] = true
                    return code
                }
                return code
            }
            
            #if canImport(AppKit)
            func font(ofSize: CGFloat) -> NSFont {
                return NSFont(name: familyName, size: ofSize) ?? .systemFont(ofSize: ofSize)
            }
            #elseif canImport(UIKit)
            func font(ofSize: CGFloat) -> UIFont {
                return UIFont(name: familyName, size: ofSize) ?? .systemFont(ofSize: ofSize)
            }
            #endif
            
            func attributedString(fontSize: CGFloat, attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
                let string = string
                guard let font = UIFont(name: familyName, size: fontSize) else {
                    assertionFailure()
                    return .init()
                }
                var attributes = attributes
                attributes[.font] = font
                return .init(string: string, attributes: attributes)
            }
            
        }

        private extension AutoAssetIconFont {
            
            @available(iOS 9.0, macOS 10.11, tvOS 6.0, watchOS 2.0, *)
            func data() -> Foundation.Data {
                if let url = Bundle(for: Self.self).url(forResource: bundle, withExtension: "bundle"),
                   let bundle = Bundle(url: url),
                   let data = NSDataAsset(name: dataName, bundle: bundle)?.data {
                    return data
                }
                
                if let data = NSDataAsset(name: dataName, bundle: Bundle.main)?.data {
                    return data
                }
                
                assertionFailure("can't find data: \(dataName) in bundle: \(bundle)")
                return Foundation.Data()
            }
            
            func register(data: Data) throws {
                guard let provider = CGDataProvider(data: data as CFData),
                      let font = CGFont(provider) else {
                          return
                      }
                
                var error: Unmanaged<CFError>?
                
                if CTFontManagerRegisterGraphicsFont(font, &error) == false, let error = error?.takeUnretainedValue() {
                    throw error
                }
            }
            
            func isAvailable(familyName: String) -> Bool {
                #if canImport(AppKit)
                return NSFontManager.shared.availableFontFamilies.contains(familyName)
                #elseif canImport(UIKit)
                return !UIFont.fontNames(forFamilyName: familyName).isEmpty
                #else
                return false
                #endif
            }
            
        }
        """#
    }
    
}
