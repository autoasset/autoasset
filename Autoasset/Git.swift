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

    let config: Config.Git
    let tag: Tag

    init(config: Config.Git) {
        self.config = config
        self.tag = Tag()
    }

    class Tag {

        func nextVersion() throws -> Int {
            let code = "git ls-remote --tag origin | sort -t '/' -k 3 -V"
            try runAndPrint(bash: code)
            let tagVersion = run(bash: code).stdout
                .components(separatedBy: "\n")
                .filter({ $0.last?.isNumber ?? false })
                .last?
                .components(separatedBy: "\t")
                .last?
                .components(separatedBy: "/")
                .last ?? "0"

            guard let version = Int(argument: tagVersion) else {
                throw RunError(message: "无法解析版本号, version: \(tagVersion), 请使用 1/2/3/4/5 Int类型")
            }

            return version + 1
        }

        func addTag(version: String) {
            try? runAndPrint(bash: "git tag -a \(version) -m 'version: \(version)'")
        }

    }

    func diff() -> String {
        return run(bash: "git diff").stdout
    }

    func commit(message: String) {
        try? runAndPrint(bash: "git add \(config.projectPath)")
        try? runAndPrint(bash: "git commit -m '\(message)'")
    }

    func fetch() {
        try? runAndPrint(bash: "git fetch")
    }

    func pull() {
        try? runAndPrint(bash: "git pull")
    }

    func push(version: String) {
        switch config.platform {
        case .github:
            try? runAndPrint(bash: "git push origin master")
        case .gitlab:
            try? runAndPrint(bash: "git push -u origin master")
        }
        try? runAndPrint(bash: "git push -u origin master \(version)")
    }

}
