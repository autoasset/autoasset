//
//  Config.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem
import Yams

struct Config {
    
    let dirPath: FilePath
    
    class Warn {
        let output: URL
        init?(json: JSON) {
            guard let url = json["output"].fileURL else {
                return nil
            }
            output = url
        }
    }
    
    let warn: Warn?
    let git: GitModel
    let mode: ModeModel
    let asset: AssetModel
    let podspec: PodspecModel?
    let message: MessageModel?
    
    init(json: JSON) throws {
        let mode  = ModeModel(json: json["mode"])
        self.mode = mode
        podspec = PodspecModel(json: json["podspec"])
        message = MessageModel(json: json["message"])
        warn    = Warn(json: json["warn"])

        var filePath = try FilePath(path: "./")
        if mode.types.contains(.normal) || mode.types.contains(.pod_with_branch) {
            while true {
                if try filePath
                    .subFilePaths(predicates: [.custom({ $0.type == .folder })])
                    .contains(where: { $0.type == .folder && $0.attributes.name == ".git" }) {
                    break
                }

                guard let parentFolder = filePath.parentFolder() else {
                    break
                }

                filePath = parentFolder
            }
            git = try GitModel(json: json["git"])
            dirPath = filePath
        } else {
            git = try GitModel(json: JSON())
            dirPath = filePath
        }

        if mode.types.contains(.normal) {
            asset = AssetModel(json: json["asset"], base: filePath.url.appendingPathComponent(GitModel.Clone.output))
        } else {
            asset = AssetModel(json: json["asset"], base: dirPath.url)
        }

    }
    
    init(url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    init(data: Data) throws {
        do {
            try self.init(json: try JSON(data: data))
        } catch {
            guard let text = String(data: data, encoding: .utf8), let yml = try Yams.load(yaml: text) else {
                throw RunError(message: "config: yml 解析失败")
            }
            try self.init(json: JSON(yml))
        }
    }
    
}
