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
    static let configuration = CommandConfiguration(version: "1")
    @Option(name: [.short, .customLong("config")], help: "配置")
    var config: String

    func run() throws {
        let config = try Config(url: FilePath(path: self.config, type: .file).url)
        try Autoasset(config: config).start()
    }

}

Main.main()
