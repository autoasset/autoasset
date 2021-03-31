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
import AutoassetModels
import Logging

public struct XcassetsController {
    
    let xcassets: Xcassets

    public init(model: Xcassets) {
        self.xcassets = model
    }
    
    public func run() throws {
        let colorController = ColorXcassetsController(asset: xcassets)
        try colorController.run()
        
        let imageController = ImageXcassetsController(xcassets: xcassets)
        try imageController.run()
        
        let gifsController = DataXcassetsController(named: .gifs, resources: xcassets.gifs, xcassets: xcassets)
        try gifsController.run()
        
        let dataController = DataXcassetsController(named: .data, resources: xcassets.datas, xcassets: xcassets)
        try dataController.run()
    }
    
}
