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
import VariablesMaker
import ASError

public struct TidyController {
    
    private let logger = Logger(label: "tidy")
    
    private let tidy: Tidy
    private let variablesMaker: VariablesMaker
    
    public init(tidy: Tidy, variables: Variables) {
        self.tidy = tidy
        self.variablesMaker = VariablesMaker(variables)
    }
    
    public func run(name: String) throws {
        let flag1 = try clearTask(name)
        let flag2 = try copyTask(name)
        let flag3 = try createTask(name)
        
        if flag1 || flag2 || flag3 { } else {
            logger.error(.init(stringLiteral: "未查询到任务: \(name)"))
        }
    }
    
}

extension TidyController {
    
    func createTask(_ name: String) throws -> Bool {
        guard let item = tidy.create.first(where: { $0.name == name }) else {
            return false
        }
        
        logger.info(.init(stringLiteral: "任务: \(name)"))
        
        var type: Tidy.CreateInput
        switch item.type {
        case .input(let result):
            type = .input(try variablesMaker.textMaker(result))
        case .text(let result):
            type = .text(try variablesMaker.textMaker(result))
        }
        
        let model = try Tidy.Create(name: name,
                                    type: type,
                                    output: variablesMaker.textMaker(item.output))
        
        var text: String
        switch model.type {
        case .input(let path):
            let input = try FilePath.File(path: path).data()
            text = String(data: input, encoding: .utf8) ?? ""
        case .text(let result):
            text = result
        }
        
        text = try variablesMaker.textMaker(text)
        let output = try FilePath.File(path: model.output)
        try? output.delete()
        logger.info(.init(stringLiteral: "正在创建: \(model.output)"))
        try output.create(with: text.data(using: .utf8))
        
        return true
    }
    
    func clearTask(_ name: String) throws -> Bool {
        guard let item = tidy.clears.first(where: { $0.name == name }) else {
            return false
        }
        logger.info(.init(stringLiteral: "任务: \(name)"))
        
        let model = try Tidy.Clear(name: name, inputs: item.inputs.map(variablesMaker.textMaker(_:)))
        
        for input in model.inputs {
            do {
                logger.info("正在移除: \(input)")
                try FilePath(path: input).delete()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
        
        return true
    }
    
    func copyTask(_ name: String) throws -> Bool {
        guard let item = tidy.copies.first(where: { $0.name == name }) else {
            return false
        }
        logger.info(.init(stringLiteral: "任务: \(name)"))
        
        let model = try Tidy.Copy(name: name,
                                  inputs: item.inputs.map(variablesMaker.textMaker(_:)),
                                  output: variablesMaker.textMaker(item.output))
        
        
        let output = try FilePath.Folder(path: model.output)
        _ = try? output.create()
        
        for input in model.inputs.compactMap({ try? FilePath(path: $0) }) {
            switch input.type {
            case .file:
                try input.copy(into: output)
                logger.info("正在复制: \(input.url.path) 至 \(output.url.path)")
            case .folder:
                let folder = FilePath.Folder(url: input.url)
                try folder.subFilePaths().forEach { item in
                    logger.info("正在复制: \(item.url.path) 至 \(output.url.path)")
                    try item.copy(into: output)
                }
            }
        }
        
        return true
    }
    
}
