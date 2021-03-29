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
import AutoassetModels
import StemCrossPlatform
import Logging

public struct TidyController {
    
    public let model: Tidy
    private let logger = Logger(label: "tidy")
    
    public init(model: Tidy) {
        self.model = model
    }
    
    public func run(name: String) throws {
        try clearTask(name)
        try copyTask(name)
    }
    
}


extension TidyController {
    
    func create() {
        
    }
    
    func clearTask(_ name: String) throws {
        model.clears.first(where: { $0.name == name })?.inputs.forEach {
            do {
                logger.info("正在移除: \($0)")
                try FilePath(path: $0).delete()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
    
    func copyTask(_ name: String) throws {
        guard let item = model.copies.first(where: { $0.name == name }) else {
            return
        }
        let output = try FilePath(path: item.output, type: .folder)
        for input in item.inputs.compactMap({ try? FilePath(path: $0) }) {
            logger.info("正在复制: \(output.path)")
            try input.copy(to: output)
        }
        
    }
    
}
