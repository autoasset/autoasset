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
import VariablesMaker
import AutoassetModels
import Bash
import Git
import Logging
import ASError

public struct CocoapodsController {
    
    private let model: Cocoapods
    private let logger = Logger(label: "cocoapods")
    
    public init(model: Cocoapods, variables: Variables) throws {
        let variablesMaker = VariablesMaker(variables)
        
        var git: Cocoapods.Git? = nil
        
        if let item = model.git {
            git = try .init(commitMessage: variablesMaker.textMaker(item.commitMessage),
                            pushMode: item.pushMode)
        }
        
        var trunk: Cocoapods.Trunk? = nil
        if let item = model.trunk {
            switch item {
            case .git(url: let url):
                trunk = .git(url: try variablesMaker.textMaker(url))
            case .github:
                trunk = .github
            }
        }
        
        self.model = try Cocoapods(trunk: trunk,
                                   git: git,
                                   podspec: variablesMaker.textMaker(model.podspec))
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
        return try shell("pod repo list", logger: logger)
            .components(separatedBy: "\n\n")
            .filter { $0.contains(url) }
            .first?
            .split(separator: "\n")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func run() throws {
        try shell("pod --version", logger: logger)
        let filePath = model.podspec
        let rootPath = try FilePath(path: "./").path
        try shell("pod lib lint \(filePath) --allow-warnings", logger: logger)
        
        guard let gitConfig = model.git else {
            return
        }
        
        let git = Git()
        
        switch gitConfig.pushMode {
        case .branch:
            try? git.add(path: rootPath)
            try? git.commit(options: [.message(gitConfig.commitMessage)])
            try? git.push()
        case .tag:
            guard let trunk = model.trunk else {
                return
            }
            let data = try FilePath(path: filePath, type: .file).data()
            guard let version = String(data: data, encoding: .utf8)?
                    .split(separator: "\n")
                    .filter({ $0.contains("s.version") })
                    .first?
                    .filter(\.isNumber) else {
                return
            }
            
            do {
                try? git.add(path: ".")
                try  git.commit(options: [.message(gitConfig.commitMessage)])
                try? git.push(options: [.delete, .refspec(version)])
                try? git.tag(options: [.delete], tagname: version)
                try  git.tag(tagname: version)
                try git.push(options: [.repository("origin"), .refspec(version)])
                switch trunk {
                case .github:
                    try shell("pod trunk push \(filePath) --allow-warnings", logger: logger)
                case .git(url: let url):
                    let url = url
                    var repoName = try getRepoName(url)
                    
                    if repoName == nil, let name = url.split(separator: "/").last?.split(separator: ".").first {
                        try shell("pod repo add \(name) \(url)", logger: logger)
                        repoName = try getRepoName(url)
                    }
                    
                    guard let name = repoName else {
                        throw ASError(message: "无法获取对应 repo")
                    }
                    
                    try shell("pod repo push \(name) \(filePath) --allow-warnings", logger: logger)
                }
            } catch {
                try? git.push(options: [.delete, .refspec(version)])
                logger.error(.init(stringLiteral: error.localizedDescription))
                throw error
            }
        case .none:
            return
        }
    }
    
}
