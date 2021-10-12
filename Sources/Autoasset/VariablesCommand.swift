//
//  File.swift
//  
//
//  Created by linhey on 2021/10/11.
//

import Foundation
import ArgumentParser
import AutoassetModels
import VariablesMaker

public struct VariablesCommand: ParsableCommand {

    public static var configuration = CommandConfiguration(commandName: "variables",
                                                           abstract:  "变量替换",
                                                           subcommands: [List.self])
    
    @Option(name: [.customLong("text"), .customShort("t")], help: "环境变量名, 例如: ${autoasset.date.now}")
    var text: String?
    
    @Option(name: [.customLong("env")], help: "环境变量文件路径")
    var envPath: String?
    
    public init() {}
    
    public func run() throws {
        let env = try envPath.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
        let result = try VariablesMaker(env, logger: nil).textMaker(text)
        print(result ?? text ?? "")
    }
    
}


extension VariablesCommand {
    
    struct List: ParsableCommand {
        
        public static var configuration = CommandConfiguration(commandName: "list")
        
        func run() throws {
            print("内置变量列表:")
            PlaceHolder.systems.enumerated().forEach {
                print("\($0+1). \($1.name) : \($1.desc)")
            }
        }
        
    }
    
}
