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
    
    private let model: Tidy
    private let logger = Logger(label: "tidy")
    
    public init(model: Tidy) {
        self.model = model
    }
    
    public func run(name: String, placeholders: () throws -> [PlaceHolder]) throws {
        try clearTask(name)
        try copyTask(name)
        try createTask(name, placeholders: placeholders)
    }
    
}

extension TidyController {
    
    func textMaker(_ text: String, placeholders: [PlaceHolder]) -> String {
        var text = text
        if PlaceHolder.all.map(\.name).contains(where: { text.contains($0) }) {
            for placeHolder in placeholders {
                text = text.replacingOccurrences(of: placeHolder.name, with: placeHolder.value)
            }
        }
        return text
    }
    
    func fileMaker(_ input: String, placeholders: [PlaceHolder]) throws -> String {
        guard let text = String(data: try FilePath(path: input, type: .file).data(), encoding: .utf8) else {
            throw ASError(message: #function)
        }
        return textMaker(text, placeholders: placeholders)
    }

}

extension TidyController {
    
    func createTask(_ name: String, placeholders: () throws -> [PlaceHolder]) throws {
        guard let item = model.create.first(where: { $0.name == name }) else {
            return
        }

        var text: String
        switch item.type {
        case .input(let path):
            let input = try FilePath(path: path, type: .file).data()
            text = String(data: input, encoding: .utf8) ?? ""
        case .text(let result):
            text = result
        }

        if PlaceHolder.all.map(\.name).contains(where: { text.contains($0) }) {
            text = self.textMaker(text, placeholders: try placeholders())
        }
        
        let output = try FilePath(path: item.output, type: .file)
        try? output.delete()
        try output.create(with: text.data(using: .utf8))
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
