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
import Git
import Logging
import VariablesMaker

public struct DownloadController {
    
    public let model: Download
    let logger = Logger(label: "download")
    let gitLogger = Logger(label: "download.git")

    public init(model: Download, variables: Variables) throws {
        let variablesMaker = VariablesMaker(variables)
        self.model = try .init(gits: model.gits.map({ item -> Download.Git in
            return try .init(name: item.name,
                             input: variablesMaker.textMaker(item.input),
                             output: variablesMaker.textMaker(item.output),
                             branch: variablesMaker.textMaker(item.branch))
        }))
    }
    
    public func run(name: String) throws {
        guard let task = model.gits.first(where: { $0.name == name }) else {
            return
        }
        
        let git = Git(logger: gitLogger)
        let desc = [task.input, task.branch, task.output].joined(separator: " ")
        logger.info(.init(stringLiteral: desc))
        try git.clone(url: task.input,
                      options: [.singleBranch, .depth(1), .branch(task.branch)],
                      to: task.output)
    }
}
