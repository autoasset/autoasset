//
//  File.swift
//  
//
//  Created by linhey on 2021/9/29.
//

import Foundation
import StemCrossPlatform
import AutoassetModels
import VariablesMaker
import Logging

struct IconFontCodeTemplate {
    
    let folder: FilePath.Folder
    let logger: Logger
    
    func createDefaultFiles() throws {
        logger.info("创建: autoasset_color_protocol.swift")
        try folder.create(file: "autoasset_color_protocol.swift", data: template_protocol().data(using: .utf8))
        logger.info("创建: autoasset_color.swift")
        try folder.create(file: "autoasset_color.swift", data: template_core().data(using: .utf8))
    }
    
    func createListFile(colors: [Color]) throws {
        let list = colors.map({ item -> String in
            let light_hex  = item.light.hexString(prefix: .none)
            let dark_hex   = item.dark.hexString(prefix: .none)
            let light_values = item.light.rgbSpace.intUnpack
            let dark_values  = item.dark.rgbSpace.intUnpack
            return "   static var \(): Self { .init(code: "\u{e610}", in: "", familyName: "iconfont") }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAssetColorProtocol {\n\(list)\n}"
        try folder.create(file: "autoasset_color_list.swift", data: str.data(using: .utf8))
    }
    
}

private extension IconFontCodeTemplate {
    
    func listFileName(_ string: String) -> String {
        guard folder.file(name: string + ".swift").isExist else {
            return string + ".swift"
        }
        return listFileName(string + "_EX")
    }
    
}

private extension IconFontCodeTemplate {
    
    func template_protocol() -> String {
        #"""
        protocol AutoAssetIconFontProtocol {
            init(code: String, in bundle: String, familyName: String)
        }
        """
    }
    
    func template_core() -> String {
        #"""
        public class AutoAssetIconFont: AutoAssetIconFontProtocol {

            let code: String
            let bundle: String
            let familyName: String
            
            private static var registerMap = [String: Bool]()
            
            required init(code: String, in bundle: String, familyName: String) {
                self.code = code
                self.bundle = bundle
                self.familyName = familyName
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
                   let data = NSDataAsset(name: familyName, bundle: bundle)?.data {
                    return data
                }
                
                if let data = NSDataAsset(name: familyName, bundle: Bundle.main)?.data {
                    return data
                }
                
                assertionFailure("can't find data: \(familyName) in bundle: \(bundle)")
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

        """
    }
    
}
