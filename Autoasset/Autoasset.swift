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

    var config: Config

    init(config: Config) throws {
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
            if try git.diff().isEmpty {
                try Message(config: config.message)?.output(version: config.mode.variables.version, branch: name)
            } else {
                try pushToGit(git)
                try Warn.output(config: config.warn)
                try Message(config: config.message)?.output(version: config.mode.variables.version, branch: name)
            }
        case .test_warn:
            Warn.test()
            try Warn.output(config: config.warn)
        case .test_message:
            try Message(config: config.message)?.output(version: config.mode.variables.version, branch: "test")
        case .test_podspec:
            guard let podspec = Podspec(config: config.podspec) else {
                return
            }
            try podspec.version()
            let version = automaticVersionFromGitBranch(config: config.mode.variables)
            try podspec.output(version: version)
            try podspec.lint()
        case .local:
            try Asset(config: config.asset).run()
            try Warn.output(config: config.warn)
        case .normal_without_git_push:
            let podspec = Podspec(config: config.podspec)
            let git = Git()
            let version = automaticVersionFromNextGitTag(git: git, config: config.mode.variables)
            try normal_without_git_push(config: config, git: git, podspec: podspec, version: version)
        case .test_config:
            break
        case .normal:
            try normalMode()
        }
    }

    func start(with types: [ModeModel.Style]) throws {
        for type in types {
            RunPrint.create(title: "mode type: \(type) ")
            try start(with: type)
        }
    }

    func normal_without_git_push(config: Config, git: Git, podspec: Podspec?, version: String) throws {
        guard try git.isInsideWorkTree() else {
            Warn.init("模式 'normal' 需要在 git 仓库中才能执行")
            return
        }

        try downloadGitInput(git: git, config: config.git)
        try Asset(config: config.asset).run()
        try FilePath(path: GitModel.Clone.output, type: .folder).delete()

        try podspec?.output(version: version)
        try podspec?.lint()
    }
    
    func normalMode() throws {
        let podspec = Podspec(config: config.podspec)
        let git = Git()
        let version = automaticVersionFromNextGitTag(git: git, config: config.mode.variables)
        try normal_without_git_push(config: config, git: git, podspec: podspec, version: version)

        do { try pushToGit(git) } catch {}
        do { try git.tag.remove(version: version) } catch {}
        do { try git.tag.add(version: version, message: commitMessage()) } catch {}
        do { try git.tag.push(version: version) } catch {}

        try podspec?.push()

        try Warn.output(config: config.warn)
        try Message(config: config.message)?.output(version: version, branch: version)
    }

}

private extension Autoasset {
    
    func commitMessage() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return "[ci skip] author: autoasset(\(Env.version)), date: \(dateFormatter.string(from: Date()))"
    }
    
    func pushToGit(_ git: Git) throws {
        try git.addAllFile(path: try git.rootPath())
        try git.commit(message: commitMessage())
        try git.push()
    }

    /// 下载目标文件
    func downloadGitInput(git: Git, config: GitModel) throws {
        try FilePath(path: GitModel.Clone.output, type: .folder).delete()
        try config.inputs.forEach { item in
            try item.branchs.forEach { branch in
                try git.clone.get(url: item.url, branch: branch, to: item.folder(for: branch))
            }
        }
    }
    
}

/// Version
private extension Autoasset {

    func automaticVersionFromNextGitTag(git: Git, config: ModeModel.Variables) -> String {
        do {
            guard let lastVersion = try git.tag.lastVersion() else {
                return "0"
            }
            
            let nameFormatter = NameFormatter()
            let numbers = nameFormatter.scanNumbers(lastVersion)
            
            guard let value = Int(numbers) else {
                return "0"
            }
            
            return String(describing: value + 1)
        } catch {
            return "0"
        }
    }
    
    func automaticVersionFromGitBranch(config: ModeModel.Variables) -> String {
        do {
            guard config.enableAutomaticVersionNumberGeneration else {
                return config.version
            }
            let formatter = NameFormatter(split: [])
            let name = try Git().branch.currentName()
            let newVersion = formatter.scanNumbers(name)
            if newVersion.isEmpty {
                return config.version
            } else {
                return newVersion
            }
        } catch {
            return config.version
        }
    }
    
}
