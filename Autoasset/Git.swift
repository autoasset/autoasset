//
//  Git.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/2.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell

class Git {

   static func lastTagVersion() throws -> Int {
        let hex = run("git", "rev-list", "--tags", "--max-count=1").stdout
        if hex.isEmpty {
            return 0
        }

        let version = run("git", "describe", "--tags", hex).stdout
        if let version = Int(argument: version) {
            return version
        }

        throw RunError(message: "无法解析版本号, hex: \(hex), version: \(version), 请使用 1/2/3/4/5 Int类型")
    }

}
