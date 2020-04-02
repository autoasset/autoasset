//
//  Podspec.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell
import Stem

class Podspec {

    let template: String

    init(template url: URL) throws {
        template = try String(contentsOfFile: url.path, encoding: .utf8)
    }

    func output(url: URL) throws {
        let version = (try versionFromGit() + 1).string
        let resource_bundles_code = """
        s.resource_bundles = {
          'Assets' => ['Sources/Assets/*.xcassets']
         }
        """

        try template.replacingOccurrences(of: "[version]", with: version)
            .replacingOccurrences(of: "[resource_bundles]", with: resource_bundles_code)
            .data(using: .utf8)?
            .write(to: url)
    }

    private func versionFromGit() throws -> Int {
        let hex = run("git", "rev-list", "--tags", "--max-count=1").stdout
        if hex.isEmpty {
            return 0
        }

        let version = run("git", "describe", "--tags", hex).stdout
        if let version = Int(argument: version) {
            return version
        }

        throw RunError(message: "无法解析版本号, hex: \(hex), version: \(version), 请使用 1/2/3/4/5 数字类型")
    }

}



