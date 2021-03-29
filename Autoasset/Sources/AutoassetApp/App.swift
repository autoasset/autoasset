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
import ArgumentParser
import StemCrossPlatform
import Yams
import AutoassetModels
import AutoassetXcassets
import AutoassetDownload
import AutoassetCocoapods
import AutoassetTidy
import Git

public struct AutoAsset: ParsableCommand {
    
    struct Error: LocalizedError {
        
        public let message: String
        public let code: Int
        public var errorDescription: String?
        
        public init(message: String, code: Int = 0) {
            self.message = message
            self.errorDescription = message
            self.code = code
        }
    }
    
    public struct Environment {
        public let rootURL: URL
        public let config: Config
    }
    
    public static let configuration = CommandConfiguration(version: "26")
    public private(set) static var environment = Environment(rootURL: URL(string: "./")!, config: .init(from: JSON()))
    public var environment: Environment { Self.environment }
    
    @Argument(help: "配置文件路径")
    var config: String
    @Flag() var verbose = false
    
    public init() {}
    
    public func run() throws {
        let path = try FilePath(path: config, type: .file)
        let data = try path.data()
        guard let text = String(data: data, encoding: .utf8), let yml = try Yams.load(yaml: text) else {
            return
        }
        let model = Config(from: JSON(yml))
        AutoAsset.environment = .init(rootURL: path.url.deletingLastPathComponent(), config: model)
        begin()
    }
}

extension AutoAsset {
    
    func begin() {
        do {
            let placeholder = try placeholder(variables: environment.config.variables)
            try environment.config.modes.forEach(run(with:))
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func placeholder(variables: Variables) throws -> PlaceHolder {
        let version: String
        switch variables.version {
        case .fromGitBranch:
            let output = try Git().revParse(output: [.abbrevRef(names: ["HEAD"])])
            let branch = output.filter(\.isNumber)
            guard branch.isEmpty == false else {
                throw Error(message: "无法从分支中提取版本号 branch: \(output)")
            }
            version = branch
        case .nextGitTag:
            let output = try Git().lsRemote(mode: [.tags], options: [.refs], repository: "origin")
            let tag = output
                .split(separator: "\n")
                .compactMap { $0.split(separator: "\t").last?.filter(\.isNumber) }
                .compactMap { Int($0) }
                .sorted(by: >)
                .first ?? 0
            version = "\(tag + 1)"
        case .text(let text):
            version = text
        }
        return PlaceHolder(version: version)
    }
    
    func run(with mode: Mode) throws {
        switch mode {
        case .download:
            if let model = environment.config.download {
                try DownloadController(model: model).run()
            }
        case .cocoapods:
            if let model = environment.config.cocoapods {
                try CocoapodsController(model: model).run()
            }
        case .tidy(name: let name):
            try TidyController(model: environment.config.tidy).run(name: name)
        case .xcassets:
            try XcassetsController(model: environment.config).run()
        }
    }
    
}
