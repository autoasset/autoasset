//
//  Message.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/13.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

class Message {

    let config: Config.Message

    init?(config: Config.Message?) {
        guard let config = config else {
            return nil
        }
        self.config = config
    }

    func output(version: String) throws {
        let message = config.template.replacingOccurrences(of: Placeholder.version, with: version)
        try message.data(using: .utf8)?.write(to: config.outputPath, options: [.atomicWrite])
        RunPrint(message)
    }

}
