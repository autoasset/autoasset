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
                                                    subcommands: [Copy.self],
                                                    defaultSubcommand: Copy.self)
    
    init() {}
    
    func run() throws {}
    
}

extension TidyCommand {
    
    struct Copy: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "复制 文件/文件夹")
        
        @Option(name: [.customLong("inputs"), .customShort("i")], help: "输入路径组")
        var inputs: [String]
        
        @Option(name: [.customLong("output"), .customShort("o")], help: "输出路径")
        var output: String
        
        @Option(name: [.customLong("env")], help: "环境变量文件路径")
        var envPath: String?
        
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
            let env = try envPath.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
            let variablesMaker = VariablesMaker(env, logger: debug > 0 ? .init(label: "tidy.copy.variables") : nil)
            try TidyController.copy(with: .init(name: "copy",
                                                inputs: inputs.map(variablesMaker.textMaker(_:)),
                                                output: variablesMaker.textMaker(output)), logger: nil)
        }
        
    }
    
}
