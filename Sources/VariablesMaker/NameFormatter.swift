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

public class NameFormatter {
    
    /// 系统保留字
    static let reservedWords = ["class", "deinit", "enum", "extension", "func", "import",
                                "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var"]
        + ["break", "case", "continue", "default", "do", "else", "fallthrough",
           "if", "in", "for", "return", "switch", "where", "while"]
        + ["as", "is", "super", "self", "Self", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__"]
        + ["inout", "operator"]
    
    /// 分割字符
    private let splitChars: [String]
    
    /// [27] 翻译中文成拼音 | default: false
    /// [27] Translate Chinese to Pinyin
    public var enableTranslateVariableNameChineseToPinyin: Bool = false
    
    public init(split: [String] = []) {
        self.splitChars = split
    }

    /// 获取文件名
    public func file(_ str: String) -> String {
        var name = str
        for char in splitChars {
            if let first = name.components(separatedBy: char).first {
                name = first
            }
        }
        return name
    }
    
    /// 处理变量名
    public func variable(_ str: String, prefix: String? = nil) -> String {
        if let prefix = prefix, splitChars.contains(prefix) {
            let name = variable(str, prefix: nil)
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
    
    public func transformToPinYin(_ str: String) -> String {
        let mutableString = NSMutableString(string: str)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        //去掉空格
        return String(mutableString)
    }
    
    public func isChinese(_ value: Character) -> Bool {
        return "\u{4E00}" <= value && value <= "\u{9FA5}"
    }
    
    public func scanNumbers(_ str: String) -> String {
       return str
        .filter({ $0.isNumber })
        .map({ String($0) })
        .joined()
    }
    
}

public extension NameFormatter {

    /// 驼峰
     func camelCased(_ str: String) -> String {
        return splitWords(str)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    
    /// 下划线
     func snakeCased(_ str: String) -> String {
        return splitWords(str).joined(separator: "_")
    }
    
}

public extension NameFormatter {
    
    func splitWords(_ str: String) -> [String] {
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
        return words.filter({ $0.isEmpty == false }).map({ $0.lowercased() })
    }

    
}
