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
        mode    = ModeModel(json: json["mode"])
        git     = GitModel(json: json["git"])
        podspec = PodspecModel(json: json["podspec"])
        message = MessageModel(json: json["message"])
        warn    = Warn(json: json["warn"])
        asset   = AssetModel(json: json["asset"])
    }

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
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
