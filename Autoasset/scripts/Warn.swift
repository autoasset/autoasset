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
        guard let config = config, list.isEmpty == false else {
            return
        }

        let filePath = try FilePath(url: config.output, type: .file)
        let message = list.map({ $0.message }).sorted().joined(separator: "\n")
        RunPrint("\n")
        RunPrint("WARN: " + [String](repeating: "👮", count: 37).joined())
        RunPrint([String](repeating: "-", count: 80).joined())
        RunPrint(message)
        RunPrint([String](repeating: "-", count: 80).joined())

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
    static func caseFirstCharIsNumber(caseName: String) -> Warn? {
        return nil
        // return Warn("首字母不能为数字: \n\(caseName), 已更替为 _\(caseName)")
    }

    @discardableResult
    static func duplicateFiles(baseURL: URL?, _ files: [FilePath]) -> Warn {
        if let baseURL = baseURL {
            return Warn("文件重复: \n" + files.map({ $0.path.replacingOccurrences(of: baseURL.path, with: "") }).joined(separator: "\n"))
        } else {
            return Warn("文件重复: \n" + files.map({ $0.path }).joined(separator: "\n"))
        }
    }

}
