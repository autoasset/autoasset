//
//  Message.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/13.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

class Message {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    func work(version: String) throws {
        let success = ["cocoapods 构建完成 🎉",
                       [String](repeating: "-", count: 40).joined(),
                       "project: [\(config.message.projectName)]",
            "version: [\(version)]",
            "text: \(config.message.text)"].joined()
        if let url = config.message.outputPath?.path {
            try success.write(toFile: url, atomically: true, encoding: .utf8)
        }
        RunPrint(success)
    }
}
