//
//  main.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//
import Foundation
import ArgumentParser
import Stem

struct Main: ParsableCommand {

    static let configuration = CommandConfiguration(version: Env.version)
    @Option(name: [.short, .customLong("config")], help: "配置文件")
    var config: String
    @Flag() var verbose = false

    func run() throws {
        do {
            let configURL = try FilePath(path: self.config, type: .file).url
            Env.rootURL = configURL.deletingLastPathComponent()
            let config = try Config(url: configURL)
            Env.mode = config.mode
            try Autoasset(config: config).start()
        } catch {
            if let error = error as? RunError {
                RunPrint(error.localizedDescription)
            } else if let error = error as? FilePath.Error {
                RunPrint(error.message)
            } else {
                RunPrint(error.localizedDescription)
            }
        }
    }
}

Main.main()
