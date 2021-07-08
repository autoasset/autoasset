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
import AutoassetIconFont
import AutoassetTidy
import Git
import Bash
import Logging
import VariablesMaker

public struct AutoAsset: ParsableCommand {
    
    public static let configuration = CommandConfiguration(version: "29")
    
    @Option(name: [.customLong("config")], help: "配置文件路径")
    var configPath: String?
    
    @Flag(help: .init("内置变量列表:\n" + PlaceHolder.systems.map{ "- \($0.name)\n  \($0.desc)"}.joined(separator: "\n") + "\n"))
    var variables = false
    
    public init() {}
    
    public func run() throws {
        begin(path: configPath ?? "autoasset.yml", variables: nil, superConfig: nil)
    }
}

extension AutoAsset {
    
    func begin(config: Config, variables: Variables?, superConfig: Config?) throws {
        var config = config
        if config.debug == nil {
            config.debug = superConfig?.debug
        }
        
        if let placeHolders = variables?.placeHolders {
            config.variables = Variables(placeHolders: config.variables.placeHolders + placeHolders,
                                         dateFormat: config.variables.dateFormat)
            
        }
        
        do {
            try config.modes.forEach { try run(with: $0, config: config) }
        } catch {
            do {
                if let path = config.debug?.error {
                    let output = try FilePath.File(path: path)
                    try? output.delete()
                    try output.create(with: error.localizedDescription.data(using: .utf8))
                }
                
                if let command = config.debug?.bash {
                    let variablesMaker = VariablesMaker(config.variables)
                    try Bash.shell(variablesMaker.textMaker(command), logger: Logger(label: "bash"))
                }
            } catch {
                throw error
            }
        }
    }
    
    
    func begin(path: String, variables: Variables?, superConfig: Config?) {
        do {
            let logger = Logger(label: "config")
            logger.info(.init(stringLiteral: "path: \(path)"))
            let path = try FilePath.File(path: path)
            let data = try path.data()
            guard let text = String(data: data, encoding: .utf8),
                  let yml = try Yams.load(yaml: text) else {
                return
            }
            try self.begin(config: Config(from: JSON(yml)), variables: variables, superConfig: superConfig)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func run(with mode: Mode, config: Config) throws {
        switch mode {
        case .iconfont:
           try config.iconfonts.forEach { iconfont in
                try IconFontController(iconfont).run()
            }
        case .download(name: let name):
            if let model = config.download {
                try DownloadController(model: model, variables: config.variables).run(name: name)
            }
        case .cocoapods:
            if let model = config.cocoapods {
                try CocoapodsController(model: model, variables: config.variables).run()
            }
        case .tidy(name: let name):
            let tidyController = TidyController(tidy: config.tidy, variables: config.variables)
            try tidyController.run(name: name)
        case .xcassets:
            try XcassetsController(model: config.xcassets, variables: config.variables).run()
        case .config(name: let name):
            guard let item = config.configs.first(where: { $0.name == name }) else {
                return
            }
            let variablesMaker = VariablesMaker(config.variables)
            
            let placeHolders = try item.variables.placeHolders.reduce([String: String]()) { (result, item) -> [String: String] in
                switch item {
                case .custom(key: let key, value: let value):
                    var result = result
                    result.updateValue(try variablesMaker.textMaker(value), forKey: key)
                    return result
                default:
                    return result
                }
            }
            
            try item.inputs.forEach {
                try begin(path: variablesMaker.textMaker($0),
                          variables:.init(placeHolders: placeHolders),
                          superConfig: config)
            }
        case .bash(command: let command):
            let variablesMaker = VariablesMaker(config.variables)
            try Bash.shell(variablesMaker.textMaker(command), logger: Logger(label: "bash"))
        }
    }
    
}
