//
//  NameFormatter.swift
//  Autoasset
//
//  Created by 林翰 on 2020/12/4.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class NameFormatter {
    
    /// 系统保留字
    static let reservedWords = ["class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var"] + ["break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while"] + ["as", "is", "super", "self", "Self", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__"] + ["inout", "operator"]
    
    /// 分割字符
    private let splitChars: [String]
    
    /// [27] 翻译中文成拼音 | default: false
    /// [27] Translate Chinese to Pinyin
    var enableTranslateVariableNameChineseToPinyin: Bool = false
    
    init(split: [String] = []) {
        self.splitChars = split
    }
    
    /// 驼峰
    func camelCased(_ str: String) -> String {
        var words = [String]()
        var buffer = [String]()
        var bufferIsNumber = false
        
        for item in str {
            let char = String(item)
            
            if splitChars.contains(char) {
                words.append(buffer.joined())
                buffer.removeAll()
                continue
            }
            
            /// 切割非法字符
            guard item.isNumber || ("a"..."z").contains(item.lowercased()) else {
                words.append(buffer.joined())
                buffer.removeAll()
                continue
            }
            
            guard item.isLowercase else {
                words.append(buffer.joined())
                buffer.removeAll()
                buffer.append(char)
                continue
            }
            
            /// 切割数字/字母
            if buffer.isEmpty {
                bufferIsNumber = item.isNumber
            }
                        
            if item.isNumber == bufferIsNumber {
                buffer.append(char)
            } else {
                words.append(buffer.joined())
                buffer.removeAll()
                buffer.append(char)
            }
        }
        
        words.append(buffer.joined())
    
        return words
            .filter({ $0.isEmpty == false })
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }

    /// 获取文件名
    func fileName(_ str: String) -> String {
        var name = str
        for char in splitChars {
            if let first = name.components(separatedBy: char).first {
                name = first
            }
        }
        return name
    }
    
    /// 处理变量名
    func variableName(_ str: String, prefix: String? = nil) -> String {
        
        if let prefix = prefix, splitChars.contains(prefix) {
            let name = variableName(str, prefix: nil)
            if name.hasPrefix(prefix) {
                return name
            } else {
                return prefix + name
            }
        }
        
        var name = "\(prefix ?? "")\(str)"
                    
        if enableTranslateVariableNameChineseToPinyin {
            name = name.map({ char -> String in
                if isChinese(char) {
                    return " \(transformToPinYin(String(char))) "
                } else {
                    return String(char)
                }
            }).joined()
        }
        
        name = camelCased(name)
        
        if name.first?.isNumber ?? false {
            return "_\(name)"
        } else if Self.reservedWords.contains(name) {
            return "`\(name)`"
        } else {
            return name
        }
        
    }
    
    func transformToPinYin(_ str: String) -> String {
        let mutableString = NSMutableString(string: str)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        //去掉空格
        return String(mutableString)
    }
    
    func isChinese(_ value: Character) -> Bool {
        return "\u{4E00}" <= value && value <= "\u{9FA5}"
    }
    
    func scanNumbers(_ str: String) -> String {
       return str
        .filter({ $0.isNumber })
        .map({ String($0) })
        .joined()
    }
    
}
