//
//  Config.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    var fileURL: URL? {
        guard let value = string else {
            return nil
        }
        return try? FilePath(path: value, type: .file).url
    }
}

struct Config {

    struct Git {
        enum Platform: String {
            case github
            case gitlab
        }

        let projectPath: String
        let platform: Platform
    }

    struct Warn {
        let outputPath: URL?
    }

    struct Asset {
        let templatePath: URL?
        let outputPath: URL?
        let isUseInPod: Bool
    }

    struct Podspec {
        let templatePath: URL?
        let outputPath: URL?
    }

    struct Xcassets {

        let input: Input
        let output: Output

        struct Input {
            let appIconPath: URL?
            let imagesPath: URL?
            let colorsPath: URL?
            let fontsPath: URL?
            let gifsPath: URL?
        }

        struct Output {
            let appIconXcassetsPath: URL?
            let imagesXcassetsPath: URL?
            let colorsXcassetsPath: URL?
            let fontsXcassetsPath: URL?
            let gifsXcassetsPath: URL?
        }

    }

    let podspec: Podspec?
    let git: Git
    let xcassets: Xcassets
    let asset: Asset
    let warn: Warn?
    let debug: Bool

    init(json: JSON) throws {
        debug = json["debug"].boolValue
        do {
            let result = json["git"]
            git = Git(projectPath: result["project_path"].string ?? "../",
                      platform: Config.Git.Platform(rawValue: result["platform"].stringValue) ?? .github)
        }

        do {
            let result = json["asset"]
            asset = Asset(templatePath: result["template_path"].fileURL,
                            outputPath: result["output_path"].fileURL,
                            isUseInPod: json["podspec"].exists())
        }

        if json["warn"].exists() {
            let result = json["warn"]
            warn = Warn(outputPath: result["output_path"].fileURL)
        } else {
            warn = nil
        }

        if json["podspec"].exists() {
            let result = json["podspec"]
            podspec = Podspec(templatePath: result["template_path"].fileURL,
                                outputPath: result["output_path"].fileURL)
        } else {
            podspec = nil
        }

        do {
            let result = json["xcassets"]
            let input = result["input"]
            let output = result["output"]
            xcassets = Xcassets(input: Xcassets.Input(appIconPath: input["app_icon_path"].fileURL,
                                                       imagesPath: input["images_path"].fileURL,
                                                       colorsPath: input["colors_path"].fileURL,
                                                        fontsPath: input["fonts_path"].fileURL,
                                                         gifsPath: input["gifs_path"].fileURL),
                                output: Xcassets.Output(appIconXcassetsPath: output["app_icon_path"].fileURL,
                                                         imagesXcassetsPath: output["images_path"].fileURL,
                                                         colorsXcassetsPath: output["colors_path"].fileURL,
                                                          fontsXcassetsPath: output["fonts_path"].fileURL,
                                                           gifsXcassetsPath: output["gifs_path"].fileURL))
        }
    }

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(json: try JSON(data: data))
    }

    init(string: String) throws {
        try self.init(json: JSON(parseJSON: string))
    }
}
