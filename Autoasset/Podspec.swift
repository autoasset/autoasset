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

    struct Repo {
        let name: String
        let path: String
        let type: String
        let url: String

        init?(_ value: String) {
            let list = value.split(separator: "\n").map({ $0.description })
            guard list.count == 4 else {
                return nil
            }
            name = list[0]
            type = list[1].replacingOccurrences(of: "- Type: ", with: "")
            url  = list[2].replacingOccurrences(of: "- URL:  ", with: "")
            path = list[1].replacingOccurrences(of: "- Path: ", with: "")
        }

    }

    let config: Config.Podspec

    init?(config: Config.Podspec?) {
        guard let config = config else {
            return nil
        }
        self.config = config
    }

    func output(version: String) throws {
        guard let template = config.template, let output = config.outputPath else {
            return
        }
        try template
            .replacingOccurrences(of: Placeholder.version, with: version)
            .data(using: .utf8)?
            .write(to: output, options: [.atomicWrite])
    }

}

// MARK: - shell
extension Podspec {

    func repoName() throws -> String? {
        guard let repo = config.repo else {
            return nil
        }

        let repoName = try shell("pod repo list", useAssert: false).stdout
            .components(separatedBy: "\n\n")
            .compactMap({ Repo($0) })
            .first(where: { repo.url == $0.url })?
            .name

        if repoName == nil {
            try shell("pod repo add \(repo.name) \(repo.url)", useAssert: false)
            return repo.name
        } else {
            return repoName
        }

    }

    func noCleanCommond() -> String {
        return " --no-clean"
    }

    func allowWarningsCommond() -> String {
        return " --allow-warnings"
    }

    func lint() throws {
        guard let output = config.outputPath else {
            throw RunError(message: "Config: podspec/output_path 不能为空")
        }
        try shell("pod lib lint \(output)" + allowWarningsCommond() + noCleanCommond(), useAssert: false)
    }

    func push() throws {
        guard let output = config.outputPath?.path else {
            throw RunError(message: "Config: podspec/output_path 不能为空")
        }
        if let repo = try repoName() {
            try shell("pod repo push \(repo) \(output)" + allowWarningsCommond(), useAssert: false)
        } else {
            try shell("pod trunk push \(output)" + allowWarningsCommond(), useAssert: false)
        }
    }

}
