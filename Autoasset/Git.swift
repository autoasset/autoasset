//
//  Git.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/2.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

class Git {

    let config: Config.Git
    let tag: Tag
    let branch: Branch

    init(config: Config.Git) throws {
        self.config = config
        self.tag = Tag()
        self.branch = Branch()
    }

    class Branch {

        func checkout(branch: String) throws {
            try shell("git checkout \(branch)")
        }

        func `switch`(to branch: String) throws {
            do {
                try shell("git checkout \(branch)")
            } catch {
                try shell("git checkout -b \(branch)")
            }
        }

        func merge(with branch: String) throws {
            try shell("git merge \(branch)")
        }

    }

    class Tag {

        func lastVersion() throws -> String? {
            let tagVersion = try shell("git ls-remote --tag origin | sort -t '/' -k 3 -V").stdout
                .components(separatedBy: "\n")
                .filter({ $0.last?.isNumber ?? false })
                .last?
                .components(separatedBy: "\t")
                .last?
                .components(separatedBy: "/")
                .last

            return tagVersion
        }

        func nextVersion(with lastVersion: String) throws -> String {
            guard let version = Int(argument: lastVersion) else {
                throw RunError(message: "无法解析版本号, version: \(lastVersion), 请使用 1/2/3/4/5 Int类型")
            }
            return (version + 1).string
        }

        func push(version: String) throws {
            try shell("git push -u origin \(version)")
        }
        
        func remove(version: String) throws {
            try shell("git tag -d \(version)")
        }

        func add(version: String, message: String) throws {
            try shell("git tag -a \(version) -m 'version: \(message)'")
        }

    }

    func diff() throws -> String {
        return try shell("git diff").stdout
    }

    func addAllFile() throws {
        try shell("git add \(config.projectPath)")
    }

    func commit(message: String) throws {
        try shell("git commit -m '\(message)'")
    }

    func fetch() throws {
        try shell("git fetch")
    }

    func pull() throws {
        try shell("git pull")
    }

    func push() throws {
        try shell("git push")
    }

}
