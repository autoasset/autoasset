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

    let config: MessageModel

    init?(config: MessageModel?) {
        guard let config = config else {
            return nil
        }
        self.config = config
    }

    func output(version: String, branch: String) throws {
        let filePath = try FilePath(url: config.output, type: .file)
        let message = config.text
            .replacingOccurrences(of: Placeholder.branch, with: branch)
            .replacingOccurrences(of: Placeholder.version, with: version)

        RunPrint("\n")
        RunPrint("MESSAGE: " + [String](repeating: "😬", count: 35).joined())
        RunPrint([String](repeating: "-", count: 80).joined())
        RunPrint(message)
        RunPrint([String](repeating: "-", count: 80).joined())

        let data = message.data(using: .utf8)
        try filePath.delete()
        try filePath.create(with: data)
    }

}
