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
import Git

public struct TidyController {
    
    private let logger = Logger(label: "tidy")
    
    public init() {}
    
    public func run(name: String, tidy: Tidy, variables: Variables) throws {
        try clearTask(name, tidy: tidy)
        try copyTask(name, tidy: tidy)
        try createTask(name, tidy: tidy, variables: variables)
    }
    
}

public extension TidyController {
    
    func textMaker(_ text: String, variables: Variables) throws -> String {
        var text = text
        
        for key in variables.placeHolderNames {
            guard text.contains(key),
                  let placeHolder = variables.placeHolder(with: key) else {
                continue
            }
            
            switch placeHolder {
            case .custom(_, let value):
                text = text.replacingOccurrences(of: placeHolder.name, with: value)
            case .timeNow:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = variables.timeNow
                let str = dateFormatter.string(from: Date())
                text = text.replacingOccurrences(of: placeHolder.name, with: str)
            case .version:
                guard let type = variables.version else {
                    continue
                }
                switch type {
                case .fromGitBranch:
                    let output = try Git().revParse(output: [.abbrevRef(names: ["HEAD"])])
                    let branch = output.filter(\.isNumber)
                    guard branch.isEmpty == false else {
                        throw ASError(message: "无法从分支中提取版本号 branch: \(output)")
                    }
                    text = text.replacingOccurrences(of: placeHolder.name, with: branch)
                case .nextGitTag:
                    let output = try Git().lsRemote(mode: [.tags], options: [.refs], repository: "origin")
                    let tag = output
                        .split(separator: "\n")
                        .compactMap { $0.split(separator: "\t").last?.filter(\.isNumber) }
                        .compactMap { Int($0) }
                        .sorted(by: >)
                        .first ?? 0
                    text = text.replacingOccurrences(of: placeHolder.name, with: "\(tag + 1)")
                case .text(let result):
                    text = text.replacingOccurrences(of: placeHolder.name, with: result)
                }
            }
            
        }
        
        return text
    }
    
    func fileMaker(_ input: String, variables: Variables) throws -> String {
        guard let text = String(data: try FilePath(path: input, type: .file).data(), encoding: .utf8) else {
            throw ASError(message: #function)
        }
        return try textMaker(text, variables: variables)
    }
    
}

extension TidyController {
    
    func createTask(_ name: String, tidy: Tidy, variables: Variables) throws {
        guard let item = tidy.create.first(where: { $0.name == name }) else {
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
        
        text = try self.textMaker(text, variables: variables)
        let output = try FilePath(path: item.output, type: .file)
        try? output.delete()
        try output.create(with: text.data(using: .utf8))
    }
    
    func clearTask(_ name: String, tidy: Tidy) throws {
        tidy.clears.first(where: { $0.name == name })?.inputs.forEach {
            do {
                logger.info("正在移除: \($0)")
                try FilePath(path: $0).delete()
            } catch {
                logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
    
    func copyTask(_ name: String, tidy: Tidy) throws {
        guard let item = tidy.copies.first(where: { $0.name == name }) else {
            return
        }
        let output = try FilePath(path: item.output, type: .folder)
        for input in item.inputs.compactMap({ try? FilePath(path: $0) }) {
            logger.info("正在复制: \(output.path)")
            try input.copy(to: output)
        }
    }
    
}
