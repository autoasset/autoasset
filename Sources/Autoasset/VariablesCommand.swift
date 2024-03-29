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
    
    @Option(name: [.customLong("env"), .customShort("e")], help: "环境变量文件路径")
    var envPath: String?
    
    @Flag(name: [.long, .short])
    var debug: Int
    
    public init() {}
    
    public func run() throws {
        let env = try envPath.flatMap({ try Global.config(from: $0)?.variables }) ?? Variables(placeHolders: [:])
        let result = try VariablesMaker(env, logger: debug > 0 ? .init(label: "variables") : nil).textMaker(text)
        print(result ?? text ?? "")
    }
    
}


extension VariablesCommand {
    
    struct List: ParsableCommand {
        
        public static var configuration = CommandConfiguration(abstract: "打印内置的变量列表")
        
        func run() throws {
            print("内置变量列表:")
            let maxNameCount = PlaceHolder.systems.map(\.name.count).max() ?? 0
            let formatter = NumberFormatter()
            formatter.formatWidth = 2
            PlaceHolder.systems.enumerated().forEach {
                print("\(formatter.st.string(from: $0+1)!). \($1.name) \(Array(repeating: " ", count: maxNameCount - $1.name.count).joined()): \($1.desc)")
            }
        }
    }
    
}
