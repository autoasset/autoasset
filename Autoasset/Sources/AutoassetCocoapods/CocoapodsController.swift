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
import AutoassetTidy
import AutoassetModels
import Git
import SwiftShell
import Logging

public struct CocoapodsController {
    
    private let model: Cocoapods
    private let variables: Variables
    private let logger = Logger(label: "cocoapods")
    
    public init(model: Cocoapods, variables: Variables) {
        self.model = model
        self.variables = variables
    }
    
    @discardableResult
    private func shell(_ command: String) throws -> String {
        logger.info(.init(stringLiteral: command))
        let output = SwiftShell.run(bash: command)
        if output.succeeded {
            logger.info(.init(stringLiteral: output.stdout))
            return output.stdout
        } else {
            logger.error(.init(stringLiteral: command))
            logger.error(.init(stringLiteral: output.stderror))
            throw ASError(message: output.error?.description ?? output.stderror)
        }
    }
    
    struct Repo {
        let name: String
        let path: String
        let type: String
        let url: String
        
        init?(_ value: String) {
            let list = value.split(separator: "\n").map({ $0.description })
            guard list.count == 4 else {
                return nil
            }
            name = list[0]
            type = list[1].replacingOccurrences(of: "- Type: ", with: "")
            url  = list[2].replacingOccurrences(of: "- URL:  ", with: "")
            path = list[3].replacingOccurrences(of: "- Path: ", with: "")
        }
        
    }
    
    fileprivate func getRepoName(_ url: String) throws -> String? {
        return try shell("pod repo list")
            .components(separatedBy: "\n\n")
            .filter { $0.contains(url) }
            .first?
            .split(separator: "\n")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func run() throws {
        try shell("pod --version")
        let file = try FilePath(path: model.podspec)
        try shell("pod lib lint \(file.path) --allow-warnings")
        
        guard let gitConfig = model.git else {
            return
        }
        
        let git = Git()
        let tidy = TidyController()

        switch gitConfig.pushMode {
        case .branch:
            _ = try tidy.textMaker(gitConfig.commitMessage, variables: variables)
            try? git.add(path: file.path)
            try? git.commit(options: [.message(gitConfig.commitMessage)])
            try? git.push()
        case .tag:
            guard let trunk = model.trunk else {
                return
            }
            
            let message = try tidy.textMaker(gitConfig.commitMessage, variables: variables)
            try? git.add(path: file.path)
            try? git.commit(options: [.message(message)])
            try? git.push()
            
            switch trunk {
            case .github:
                try shell("pod trunk push \(file.path) --allow-warnings")
            case .git(url: let url):
                var repoName = try getRepoName(url)
                
                if repoName == nil, let name = url.split(separator: "/").last?.split(separator: ".").first {
                    try shell("pod repo add \(name) \(url)")
                    repoName = try getRepoName(url)
                }
                
                guard let name = repoName else {
                    throw ASError(message: "无法获取对应 repo")
                }
                
                try shell("pod repo push \(name) \(file.path) --allow-warnings")
            }
        case .none:
            return
        }
        
        
    }
    
}