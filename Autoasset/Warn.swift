//
//  Warn.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/27.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

class Warn {



    let message: String

    private static var list = [Warn]()

    @discardableResult
    init(_ message: String) {
        self.message = message
        Warn.list.append(self)
    }

    static func output(config: Config.Warn) throws {
        guard let url = config.outputPath else {
            Warn("无法输出 Warn 文件, 配置文件不存在")
            return
        }
        try list.map({ $0.message })
            .joined(separator: "\n")
            .write(to: url, atomically: true, encoding: .utf8)
    }

}

// MARK: -
extension Warn {

    @discardableResult
    static func caseFirstCharIsNumber(caseName: String) -> Warn {
        return Warn("首字母不能为数字: \n\(caseName), 已更替为 _\(caseName)")
    }

}
