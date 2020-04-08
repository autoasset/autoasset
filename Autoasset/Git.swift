//
//  Git.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/2.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell

@discardableResult
func shell(_ command: String) -> RunOutput {
    let out = run(bash: command)
    if Autoasset.isDebug {
        print([String](repeating: "↓", count: 80).joined())
        print("command: \(command)")
        if out.stdout.isEmpty == false {
            print("stdout: \(out.stdout)")
        }
        if out.stderror.isEmpty == false {
            print("stderror: \(out.stderror)")
        }
        print([String](repeating: "↑", count: 80).joined())
        print("\n")
    }
    return out
}

class Git {

    let config: Config.Git
    let tag: Tag

    init(config: Config.Git) {
        self.config = config
        self.tag = Tag()
    }

    class Tag {

        func nextVersion() throws -> Int? {
            let tagVersion = shell("git ls-remote --tag origin | sort -t '/' -k 3 -V").stdout
                .components(separatedBy: "\n")
                .filter({ $0.last?.isNumber ?? false })
                .last?
                .components(separatedBy: "\t")
                .last?
                .components(separatedBy: "/")
                .last

            guard let value = tagVersion else {
                return nil
            }

            guard let version = Int(argument: value) else {
                throw RunError(message: "无法解析版本号, version: \(value), 请使用 1/2/3/4/5 Int类型")
            }

            return version + 1
        }

        func push(version: String) {
            shell("git push -u origin master \(version)")
        }
        
        func remove(version: String) {
            shell("git tag -d \(version)")
        }

        func add(version: String, message: String) {
            shell("git tag -a \(version) -m 'version: \(message)'")
        }

    }

    func diff() -> String {
        return shell("git diff").stdout
    }

    func commit(message: String) {
        shell("git add \(config.projectPath)")
        shell("git commit -m '\(message)'")
    }

    func fetch() {
        shell("git fetch")
    }

    func pull() {
        shell("git pull")
    }

    func push(version: String) {
        switch config.platform {
        case .github:
            shell("git push origin master")
        case .gitlab:
            shell("git push -u origin master")
        }
    }

}
