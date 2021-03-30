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
    
    case version
    case timeNow
    case custom(key: String, value: String)

    public var name: String {
        switch self {
        case .version: return "${version}"
        case .timeNow: return "${timeNow}"
        case .custom(key: let key, _): return "${\(key)}"
        }
    }
        
}

public struct Variables {
    
    public enum Version {
        /// 当前分支名中提取版本号
        case fromGitBranch
        /// 寻找下个Tag
        case nextGitTag
        /// 自定义
        case text(String)
        
        init?(from json: JSON) {
            if let text = json["text"].string, text.isEmpty == false {
                self = .text(text)
            } else if json["nextGitTag"].boolValue {
                self = .nextGitTag
            } else if json["fromGitBranch"].boolValue {
                self = .fromGitBranch
            } else {
               return nil
            }
        }
    }
    
    public let version: Version?
    public let timeNow: String?
    public var placeHolders: [PlaceHolder]
    public var placeHolderNames: [String]
    
    public mutating func add(placeholder key: String, value: String) {
        placeHolders = placeHolders.filter { $0.name != key }
        placeHolders.append(.custom(key: key, value: value))
    }
    
    public func placeHolder(with name: String) -> PlaceHolder? {
        switch name {
        case PlaceHolder.version.name:
            return PlaceHolder.version
        case PlaceHolder.timeNow.name:
            return PlaceHolder.timeNow
        default:
            return placeHolders.first { item -> Bool in
                switch item {
                case .custom:
                    return true
                default:
                    return false
                }
            }

        }
    }
    
    init(from json: JSON) {
        
        var placeHolderNames = [String]()
        var placeHolders = [PlaceHolder]()
        var version: Version?
        var timeNow: String?
        
        json.dictionaryValue.forEach { (key, result) in
            switch key {
            case "version":
                if let value = Version(from: result) {
                    version = value
                    placeHolderNames.append(PlaceHolder.version.name)
                } else if let value = result.string, value.isEmpty == false {
                    placeHolders.append(.custom(key: PlaceHolder.version.name, value: value))
                }
            case "timeNow":
                timeNow = result.string
                placeHolderNames.append(PlaceHolder.timeNow.name)
            default:
                placeHolderNames.append(key)
                placeHolders.append(.custom(key: key, value: result.stringValue))
            }
        }
        
        self.version = version
        self.timeNow = timeNow
        self.placeHolderNames = placeHolderNames
        self.placeHolders = placeHolders
    }
    
}
