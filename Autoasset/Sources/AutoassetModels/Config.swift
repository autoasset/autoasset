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

public struct Config {
    
    public let modes: [Mode]
    public let environment: Environment
    public let warn: Warn?
    public let message: Message?
    public let cocoapods: Cocoapods?
    public let xcassets: Xcassets
    public let download: Download?
    public let tidy: Tidy
    public let variables: Variables
    
    public init(from json: JSON) {
        modes = json["modes"].arrayValue.compactMap(Mode.init(from:))
        environment = .init(from: json["environment"])
        warn = Warn(from: json["warn"])
        message = Message(from: json["message"])
        cocoapods = Cocoapods(from: json["cocoapods"])
        xcassets = Xcassets(from: json["xcassets"])
        download = Download(from: json["download"])
        tidy = Tidy(from: json["tidy"])
        variables = Variables(from: json["tidy"])
    }
    
}
