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

    static let version = "3"
    static var isDebug: Config.Debug = .normal

    let config: Config
    lazy var asset = Asset(config: config.asset)

    init(config: Config) {
        Autoasset.isDebug = config.debug
        self.config = config
    }

    func start() throws {

        switch config.debug {
        case .local:
            try Asset.start(config: config.asset)
        case .none, .normal:
            let podspec = Podspec(config: config.podspec)
            let git = try Git(config: config.git)

            if let uiBranch = config.git.ui?.branch {
                try git.branch.merge(with: uiBranch)
            }

            try Asset.start(config: config.asset)

            if let warn = config.warn {
                try Warn.output(config: warn)
            }

            let lastVersion = try? git.tag.lastVersion() ?? "0"
            let version = try git.tag.nextVersion(with: lastVersion ?? "0")
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
            try? git.tag.push(url: config.git.pushURL, version: version)

            try podspec?.push()

            try Message(config: config).work(version: version)
        }
    }

}
