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
import Bash
import Logging
import VariablesMaker

public struct AutoAsset: ParsableCommand {
    
    public static let configuration = CommandConfiguration(version: "27")
    
    @Option(name: [.customLong("config")], help: "配置文件路径")
    var configPath: String?
    
    @Flag(help: .init("内置变量列表:\n" + PlaceHolder.systems.map{ "- \($0.name)\n  \($0.desc)"}.joined(separator: "\n") + "\n"))
    var variables = false
    
    public init() {}
    
    public func run() throws {
        begin(path: configPath ?? "autoasset.yml")
    }
}

extension AutoAsset {
    
    func begin(path: String) {
        do {
            let path = try FilePath(path: path, type: .file)
            let data = try path.data()
            guard let text = String(data: data, encoding: .utf8),
                  let yml = try Yams.load(yaml: text) else {
                return
            }
            let config = Config(from: JSON(yml))
            do {
                try config.modes.forEach { try run(with: $0, config: config) }
            } catch {
                if let output = config.debug?.error {
                    let file = try FilePath(path: output, type: .file)
                    try? file.delete()
                    try file.create(with: error.localizedDescription.data(using: .utf8))
                }
                if let bash = config.debug?.bash,
                   bash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    let variablesMaker = VariablesMaker(config.variables)
                    try Bash.shell(variablesMaker.textMaker(bash), logger: Logger(label: "bash"))
                }
                throw error
            }
        } catch {
            print(error.localizedDescription)
        }
    }
        
    func run(with mode: Mode, config: Config) throws {
        switch mode {
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
            item.inputs.forEach(begin(path:))
        case .bash(command: let command):
            let variablesMaker = VariablesMaker(config.variables)
            try Bash.shell(variablesMaker.textMaker(command), logger: Logger(label: "bash"))
        }
    }
    
}
