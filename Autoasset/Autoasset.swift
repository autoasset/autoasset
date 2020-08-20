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

    static let version = "15"
    static var mode: ModeModel = .init(type: .normal, variables: .init(version: Autoasset.version))

    let config: Config

    init(config: Config) throws {
        Autoasset.mode = config.mode
        self.config = config
    }

    func start() throws {
        do {
            try start(with: config.mode.types)
        } catch {
            try Warn.output(config: config.warn)
            try Message(config: config.message)?.output(error: error.localizedDescription)
            throw error
        }
    }

}

private extension Autoasset {

    func start(with type: ModeModel.Style) throws {
        switch type {
        case .pod_with_branch:
            let git = Git()
            try Asset(config: config.asset).run()
            let name = try git.branch.currentName()
            try start(with: .test_podspec)
            try pushToGit(git)
            try Warn.output(config: config.warn)
            try Message(config: config.message)?.output(version: config.mode.variables.version, branch: name)
        case .test_warn:
            Warn.test()
            try Warn.output(config: config.warn)
        case .test_message:
            try Message(config: config.message)?.output(version: config.mode.variables.version, branch: "test")
        case .test_podspec:
            let podspec = Podspec(config: config.podspec)
            try podspec?.output(version: config.mode.variables.version)
            try podspec?.lint()
        case .local:
            try Asset(config: config.asset).run()
            try Warn.output(config: config.warn)
        case .normal:
            try normalMode()
        }
    }

    func start(with types: [ModeModel.Style]) throws {
        for type in types {
            RunPrint("+------------------ mode type: \(type) ------------------+")
            try start(with: type)
        }
    }

    func commitMessage() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY年MM月DD HH:MM"
        return "[ci skip] author: autoasset(\(Autoasset.version)), date: \(dateFormatter.string(from: Date()))"
    }

    func pushToGit(_ git: Git) throws {
        try git.addAllFile(path: config.dirPath.path)
        try git.commit(message: commitMessage())
        try git.push()
    }

    func normalMode() throws {
        let podspec = Podspec(config: config.podspec)
        let git = Git()

        /// 下载目标文件
        try FilePath(path: GitModel.Clone.output, type: .folder).delete()
        try config.git.inputs.forEach { item in
            try item.branchs.forEach { branch in
                try git.clone.get(url: item.url, branch: branch, to: item.folder(for: branch))
            }
        }

        try Asset(config: config.asset).run()
        try FilePath(path: GitModel.Clone.output, type: .folder).delete()

        let lastVersion = try? git.tag.lastVersion() ?? config.mode.variables.version
        let version = try git.tag.nextVersion(with: lastVersion ?? config.mode.variables.version)
        try podspec?.output(version: version)
        try podspec?.lint()
        
        try pushToGit(git)

        try? git.tag.remove(version: version)
        try? git.tag.add(version: version, message: commitMessage())
        try? git.tag.push(version: version)

        try podspec?.push()

        try Warn.output(config: config.warn)
        try Message(config: config.message)?.output(version: version, branch: version)
    }

}
