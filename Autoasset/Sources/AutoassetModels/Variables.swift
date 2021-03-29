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

public struct PlaceHolder {
    
    public let version: String
    
    public init(version: String) {
        self.version = version
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
        
        init(from json: JSON) {
            if let text = json["text"].string, text.isEmpty == false {
                self = .text(text)
            } else if json["nextGitTag"].boolValue {
                self = .nextGitTag
            } else if json["fromGitBranch"].boolValue {
                self = .fromGitBranch
            } else {
                self = .text("0")
            }
        }
    }
    
    public let version: Version
    
    init(from json: JSON) {
        version = Version(from: json["version"])
    }
    
}
