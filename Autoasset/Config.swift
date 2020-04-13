//
//  Config.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import Stem

extension JSON {
    var fileURL: URL? {
        guard let value = string else {
            return nil
        }
        return try? FilePath(path: value, type: .file).url
    }
}

struct Config {

    struct Message {
        let projectName: String
        let text: String
        let outputPath: URL?

        init(json: JSON) {
            projectName = json["project_name"].stringValue
                   text = json["text"].stringValue
             outputPath = json["output_path"].fileURL
        }
    }

    struct Git {

        enum Platform: String {
            case github
            case gitlab
        }

        let branch: String
        let projectPath: String
        let platform: Platform

        init(json: JSON) {
            branch = json["branch"].string ?? "master"
            projectPath = json["project_path"].string ?? "../"
            platform = Config.Git.Platform(rawValue: json["platform"].stringValue) ?? .github
        }
    }

    struct Warn {
        let outputPath: URL?

        init?(json: JSON) {
            guard json.exists() else {
                return nil
            }
           outputPath = json["output_path"].fileURL
        }
    }

    struct Asset {
        let templatePath: URL?
        let outputPath: URL?
        let isUseInPod: Bool
    }

    struct Podspec {

        struct Repo {
            let name: String
            let url: String
            init?(json: JSON) {
                guard let name = json["name"].string, let url = json["url"].string else {
                    return nil
                }
                self.name = name
                self.url = url
            }
        }

        let templatePath: URL?
        let outputPath: URL?
        let repo: Repo?
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
    let message: Message

    init(json: JSON) throws {
        debug   = json["debug"].boolValue
        message = Message(json: json["message"])
        git     = Git(json: json["git"])
        warn    = Warn(json: json["warn"])

        do {
            let result = json["asset"]
            asset = Asset(templatePath: result["template_path"].fileURL,
                            outputPath: result["output_path"].fileURL,
                            isUseInPod: json["podspec"].exists())
        }

        if json["podspec"].exists() {
            let result = json["podspec"]
            podspec = Podspec(templatePath: result["template_path"].fileURL,
                                outputPath: result["output_path"].fileURL,
                                repo: Podspec.Repo(json: result["repo"]))
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
