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
    
    let git: GitModel
    let mode: ModeModel
    let podspec: PodspecModel?
    let asset: AssetModel
    let warn: Warn?
    let message: MessageModel?
    
    init(json: JSON) throws {
        mode = ModeModel(json: json["mode"])

        podspec = PodspecModel(json: json["podspec"])
        message = MessageModel(json: json["message"])
        warn    = Warn(json: json["warn"])

        var filePath = try FilePath(path: "./")
        if mode.type == .normal {
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
            asset = AssetModel(json: json["asset"], base: filePath.url.appendingPathComponent(GitModel.Clone.output))
        } else {
            git   = try GitModel(json: JSON())
            asset = AssetModel(json: json["asset"], base: nil)
        }

        dirPath = filePath
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
