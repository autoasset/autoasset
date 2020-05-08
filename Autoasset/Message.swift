//
//  Message.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/13.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Message {

    let config: Config.Message

    init?(config: Config.Message?) {
        guard let config = config else {
            return nil
        }
        self.config = config
    }

    func output(version: String) throws {
        let filePath = try FilePath(url: config.outputPath, type: .file)
        let message = config.template.replacingOccurrences(of: Placeholder.version, with: version)
        let data = message.data(using: .utf8)
        try filePath.delete()
        try filePath.create(with: data)
        RunPrint(message)
    }

}
