//
//  File.swift
//  
//
//  Created by linhey on 2021/10/11.
//

import Foundation
import ArgumentParser
import Stem
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

public struct ConfigCommand: ParsableCommand {

    public static var configuration = CommandConfiguration(commandName: "config", abstract:  "执行配置文件")
    
    @Option(name: [.customLong("path"), .customLong("config")], help: "配置文件路径")
    var path: String
    
    @Option(name: [.customLong("env")], help: "环境变量文件路径")
    var envPath: String?
    
    public init() {}
    
    public func validate() throws {
        guard try FilePath.File(path: path).isExist else {
            throw ValidationError("配置文件不存在: \(path)")
        }
    }
    
    public func run() throws {
        if let path = envPath {
            let logger = Logger(label: "env")
            logger.info(.init(stringLiteral: "path: \(path)"))
            Global.env = try Global.config(from: path)?.variables
        }
        begin(path: path, variables: Global.env, superConfig: nil)
    }
    
}


extension ConfigCommand {
    
    func begin(config: Config, variables: Variables?, superConfig: Config?) throws {
        var config = config
        if config.debug == nil {
            config.debug = superConfig?.debug
        }
        
        config.variables = config.variables.merge(variables).merge(Global.env)
        
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
        let logger = Logger(label: "config")
        logger.info(.init(stringLiteral: "path: \(path)"))
        guard let config = try? Global.config(from: path) else {
            return
        }
        try? self.begin(config: config, variables: variables, superConfig: superConfig)
    }
    
    func run(with mode: Mode, config: Config) throws {
        switch mode {
        case .iconfonts:
            try config.iconfonts.forEach { iconfont in
                try IconFontController(iconfont, variables: config.variables).run()
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
            try XcassetsController(model: config.xcassets, variables: config.variables).run(validate: { item in
                try self.begin(config: item, variables: nil, superConfig: config)
            })
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
