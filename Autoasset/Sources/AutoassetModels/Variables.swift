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

public enum PlaceHolder {
    
    case dateNow
    case dateFormat
    case gitCurrentBranch
    case gitCurrentBranchNumber
    case gitNextTagNumber
    case custom(key: String, value: String)
    
    public static var systems: [PlaceHolder] { [.dateNow,
                                                .dateFormat,
                                                .gitCurrentBranch,
                                                .gitCurrentBranchNumber,
                                                .gitNextTagNumber] }
    
    var variable: String {
        switch self {
        case .dateNow:                 return "autoasset.date.now"
        case .dateFormat:              return "autoasset.date.format"
        case .gitCurrentBranch:        return "autoasset.git.branch.current"
        case .gitCurrentBranchNumber:  return "autoasset.git.branch.current.number"
        case .gitNextTagNumber:        return "autoasset.git.tag.next.number"
        case .custom(key: let key, _): return key
        }
    }
    
    public var desc: String {
        switch self {
        case .dateNow:                 return "获取当前时间"
        case .dateFormat:              return "设置时间格式, 默认为 yyyy-MM-dd HH:mm:ss"
        case .gitCurrentBranch:        return "获取当前 Git Branch 名称"
        case .gitCurrentBranchNumber:  return "获取当前 Git Branch 名称中的数字部分"
        case .gitNextTagNumber:        return "获取远端 Git Tags 中最大的数字, 未创建分支为 1"
        case .custom(key: _, let value): return "\(value)"
        }
    }
    
    public var name: String { "${\(variable)}" }
    
}

public struct Variables {
    
    public let dateFormat: String
    public var placeHolders: [PlaceHolder]
    public var placeHolderNames: [String]
    
    init(from json: JSON) {
        
        var placeHolderNames = PlaceHolder.systems.map(\.name)
        var placeHolders = PlaceHolder.systems
        var dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        json.dictionaryValue.forEach { (key, result) in
            switch key {
            case PlaceHolder.dateFormat.variable:
                dateFormat = result.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? dateFormat
            default:
                let placeholder = PlaceHolder.custom(key: key, value: result.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
                placeHolders.append(placeholder)
                placeHolderNames.append(placeholder.name)
            }
        }
        
        self.dateFormat = dateFormat
        self.placeHolderNames = placeHolderNames
        self.placeHolders = placeHolders
    }
    
}
