//
//  Warn.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/27.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Warn {

    let message: String

    private static var list = [Warn]()

    @discardableResult
    init(_ message: String) {
        self.message = message
        Warn.list.append(self)
    }

    static func output(config: Config.Warn?) throws {
        guard let config = config else {
            return
        }

        let filePath = try FilePath(url: config.outputPath, type: .file)
        let message = list.map({ $0.message }).sorted().joined(separator: "\n")
        let data = message.data(using: .utf8)
        try filePath.delete()
        try filePath.create(with: data)
    }

}

// MARK: -
extension Warn {

    @discardableResult
    static func test() -> Warn {
        return Warn("test: 测试")
    }

    @discardableResult
    static func caseFirstCharIsNumber(caseName: String) -> Warn {
        return Warn("首字母不能为数字: \n\(caseName), 已更替为 _\(caseName)")
    }

}
