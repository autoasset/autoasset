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

public enum Mode {
    
    case download(name: String)
    case tidy(name: String)
    case xcassets
    case iconfonts
    case cocoapods
    case config(name: String)
    case bash(command: String)

    
    init?(from json: JSON) {
        if let name = json["tidy"].string {
            self = .tidy(name: name)
        } else if let name = json["config"].string {
            self = .config(name: name)
        } else if let name = json["bash"].string {
            self = .bash(command: name)
        } else if let name = json["download"].string {
            self = .download(name: name)
        } else {
            switch json.stringValue {
            case "xcassets": self = .xcassets
            case "iconfonts": self = .iconfonts
            case "cocoapods": self = .cocoapods
            default:
                return nil
            }
        }
    }
    
}
