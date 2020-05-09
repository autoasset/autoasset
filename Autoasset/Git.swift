//
//  Git.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/2.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Git {

    let config: Config.Git
    let tag: Tag
    let branch: Branch
    let remote: Remote

    init(config: Config.Git) throws {
        self.config = config
        self.tag = Tag()
        self.branch = Branch()
        self.remote = Remote()
        if let push = config.pushURL, let pushURL = URL(string: push), let url = try remote.url() {
            guard url.host == pushURL.host, url.path == pushURL.path else {
                throw RunError(message: "config: push_url与git remote不一致, \n push_url: \(push) \n remote_url: \(url)")
            }
        }
    }

    class Remote {

        func url() throws -> URL? {
            guard var str = try shell("git remote -v")
                .stdout
                .components(separatedBy: "\n")
                .first(where: { $0.contains("git@") || $0.contains("http") })?
                .components(separatedBy: " ")
                .first(where: { $0.contains("git@") || $0.contains("http") })
                else {
                    return nil
            }
            if str.contains("git@"), let prefix = str.components(separatedBy: "git@").first {
                str = String(str.dropFirst(prefix.count))
            }

            if str.contains("http"), let prefix = str.components(separatedBy: "http").first {
                str = String(str.dropFirst(prefix.count))
            }

            return URL(string: String(str))
        }

    }

    class Branch {

        func currentName() throws -> String {
            return try shell("git rev-parse --abbrev-ref HEAD").stdout
        }

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
                .filter({ $0.contains(".") == false && $0.last?.isNumber ?? false })
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

        func push(url: String?, version: String) throws {
            if let url = url {
                try shell("git push -u \(url) \(version)")
            } else {
                try shell("git push -u origin \(version)")
            }
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
        if let url = config.pushURL {
            try shell("git push \(url)")
        } else {
            try shell("git push")
        }
    }

}
