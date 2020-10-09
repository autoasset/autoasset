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

    private(set) lazy var warn    = Warn(json: rawJSON["warn"])
    private(set) lazy var message = MessageModel(json: rawJSON["message"])
    private(set) lazy var podspec = PodspecModel(json: rawJSON["podspec"])

    let git: GitModel
    let mode: ModeModel
    let asset: AssetModel

    private let rawJSON: JSON

    init(json: JSON) throws {
        self.rawJSON = json
        git = try GitModel(json: json["git"])

        let mode  = ModeModel(json: json["mode"])
        self.mode = mode
        if mode.types.contains(.normal) {
            asset = AssetModel(json: json["asset"], base: Env.rootURL.appendingPathComponent(GitModel.Clone.output))
        } else {
            asset = AssetModel(json: json["asset"], base: Env.rootURL)
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
