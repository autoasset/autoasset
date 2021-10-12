//
//  File.swift
//  
//
//  Created by linhey on 2021/10/12.
//

import Foundation
import ArgumentParser
import AutoassetTidy
import AutoassetModels
import VariablesMaker

struct TidyCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(commandName: "tidy",
                                                    abstract:  "复制/创建/删除 文件/文件夹",
                                                    subcommands: [Copy.self,
                                                                  Clear.self,
                                                                  Create.self],
                                                    defaultSubcommand: Copy.self)
    
    init() {}
    
    func run() throws {}
    
}

extension TidyCommand {
    
    struct Create: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "创建 文件")
        
        @Option(name: [.long, .short], help: "输入路径")
        var input: String?
        
        @Option(name: [.long, .short], help: "输入文本")
        var text: String?
        
        @Option(name: [.customLong("output"), .customShort("o")], help: "输出路径")
        var output: String
        
        @Option(name: [.long, .short], help: "环境变量文件路径")
        var env: String?
        
        @Flag(name: [.long, .short])
        var debug: Int
        
        
        init() {}
        
        func validate() throws {
            guard output.isEmpty == false else {
                throw ValidationError("--output 不能为空")
            }
            
            guard input != nil || text != nil else {
                throw ValidationError("--input 与 --text 不能同时为空")
            }
        }
        
        func run() throws {
            let env = try env.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
            let variablesMaker = VariablesMaker(env, logger: debug > 0 ? .init(label: "tidy.create.variables") : nil)
            
            var createInput: Tidy.CreateInput?
            if let text = text {
                createInput = .text(text)
            } else if let input = input {
                createInput = .input(input)
            } else {
                throw ValidationError("--input 与 --text 不能同时为空")
            }
            
            try TidyController.task(with: .init(name: "create", type: createInput!, output: output),
                                    variablesMaker: variablesMaker,
                                    logger: debug > 0 ? .init(label: "tidy.create") : nil)
        }
        
    }
    
    struct Clear: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "移除 文件/文件夹")
        
        @Option(name: [.long, .short], help: "输入路径组")
        var inputs: [String]
        
        @Option(name: [.long, .short], help: "环境变量文件路径")
        var env: String?
        
        @Flag(name: [.long, .short])
        var debug: Int
        
        init() {}
        
        func validate() throws {
            guard inputs.isEmpty == false else {
                throw ValidationError("--inputs 不能为空")
            }
        }
        
        func run() throws {
            let env = try env.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
            let variablesMaker = VariablesMaker(env, logger: debug > 0 ? .init(label: "tidy.clear.variables") : nil)
            try TidyController.task(with: .init(name: "clear", inputs: inputs),
                                    variablesMaker: variablesMaker,
                                    logger: debug > 0 ? .init(label: "tidy.clear") : nil)
        }
        
    }
    
    struct Copy: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "复制 文件/文件夹 至文件夹中")
        
        @Option(name: [.long, .short], help: "输入路径组")
        var inputs: [String]
        
        @Option(name: [.long, .short], help: "输出路径")
        var output: String
        
        @Option(name: [.long, .short], help: "环境变量文件路径")
        var env: String?
        
        @Flag(name: [.long, .short])
        var debug: Int
        
        init() {}
        
        func validate() throws {
            guard inputs.isEmpty == false else {
                throw ValidationError("--inputs 不能为空")
            }
            guard output.isEmpty == false else {
                throw ValidationError("--output 不能为空")
            }
        }
        
        func run() throws {
            let env = try env.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
            let variablesMaker = VariablesMaker(env, logger: debug > 0 ? .init(label: "tidy.copy.variables") : nil)
            try TidyController.task(with: .init(name: "copy", inputs: inputs, output: output),
                                    variablesMaker: variablesMaker,
                                    logger: debug > 0 ? .init(label: "tidy.copy") : nil)
        }
        
    }
    
}
