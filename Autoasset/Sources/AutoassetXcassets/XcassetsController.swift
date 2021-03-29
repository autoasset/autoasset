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
    
    let model: Config
    var xcassets: Xcassets { model.xcassets }

    public init(model: Config) {
        self.model = model
    }
    
    public func run() throws {
        let colorController = ColorXcassetsController(model: model)
        try colorController.run()
        
        let imageController = ImageXcassetsController(model: model)
        try imageController.run()
        
        let gifsController = DataXcassetsController(model: model, named: .gifs, resources: xcassets.gifs)
        try gifsController.run()
        
        let dataController = DataXcassetsController(model: model, named: .data, resources: model.xcassets.datas)
        try dataController.run()
    }
    
}
