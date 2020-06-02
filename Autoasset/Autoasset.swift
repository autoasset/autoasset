//
//  Autoasset.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/7.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

class Autoasset {

    static let version = "9"
    static var mode: ModeModel = .init(type: .normal, variables: .init(version: Autoasset.version))

    let config: Config

    init(config: Config) throws {
        Autoasset.mode = config.mode
        self.config = config
    }

    func start() throws {

        switch config.mode.type {
        case .pod_with_branch:
            let podspec = Podspec(config: config.podspec)
            let git = try Git(config: config.git)
            try Asset(config: config.asset).run()
            let branchName = try git.branch.currentName()
            let lastVersion = branchName.split(separator: "/").last?.description ?? branchName
            let version = try git.tag.nextVersion(with: lastVersion)
            try podspec?.output(version: version)
            try podspec?.lint()
            try git.addAllFile()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY年MM月DD HH:MM"
            let message = "branch: \(version), author: autoasset(\(Autoasset.version)), date: \(dateFormatter.string(from: Date()))"
            try git.commit(message: message)
            try? git.push()
            try Warn.output(config: config.warn)
            try Message(config: config.message)?.output(version: version)
        case .test_warn:
            Warn.test()
            try Warn.output(config: config.warn)
        case .test_message:
            try Message(config: config.message)?.output(version: config.mode.variables.version)
        case .test_podspec:
            let podspec = Podspec(config: config.podspec)
            try podspec?.output(version: config.mode.variables.version)
            try podspec?.lint()
        case .local:
            try Asset(config: config.asset).run()
            try Warn.output(config: config.warn)
        case .normal:
            let podspec = Podspec(config: config.podspec)
            let git = try Git(config: config.git)

            config.git.inputs.forEach { branch in
                do {
                    try git.branch.merge(with: branch)
                } catch {
                    Warn.gitMerge(branch: branch)
                }
            }

            try Asset(config: config.asset).run()
            let lastVersion = try? git.tag.lastVersion() ?? config.mode.variables.version
            let version = try git.tag.nextVersion(with: lastVersion ?? config.mode.variables.version)
            try podspec?.output(version: version)
            try podspec?.lint()

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY年MM月DD HH:MM"
            let message = "tag: \(version), author: autoasset(\(Autoasset.version)), date: \(dateFormatter.string(from: Date()))"

            try git.addAllFile()
            try git.commit(message: message)
            try? git.push()

            try? git.tag.remove(version: version)
            try? git.tag.add(version: version, message: message)
            try? git.tag.push(version: version)

            try podspec?.push()

            try Warn.output(config: config.warn)
            try Message(config: config.message)?.output(version: version)
        }
    }

}
