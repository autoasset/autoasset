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

extension JSON {
    var fileURL: URL? {
        guard let value = string else {
            return nil
        }
        return try? FilePath(path: value, type: .file).url
    }
}

struct Config {

    enum Debug: String {
        case none
        case normal
        case local
    }

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

        struct Group {
            let branch: String
            init?(json: JSON) {
                if let branch = json["branch"].string {
                    self.branch = branch
                } else {
                    return nil
                }

            }
        }

        let pushURL: String?
        let projectPath: String
        let ui: Group?

        init(json: JSON) {
            ui = Group(json: json["ui"])
            pushURL = json["push_url"].string
            projectPath = json["project_path"].string ?? "../"
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

        struct Xcassets {

            let input: Input
            let output: Output

            struct Input {
                let appIconPath: URL?
                let imagesPath: URL?
                let colorsPath: URL?
                let fontsPath: URL?
                let gifsPath: URL?

                init(json: JSON) {
                    appIconPath = json["app_icon_path"].fileURL
                    imagesPath  = json["images_path"].fileURL
                    colorsPath  = json["colors_path"].fileURL
                    fontsPath   = json["fonts_path"].fileURL
                    gifsPath    = json["gifs_path"].fileURL
                }

            }

            struct Output {
                let appIconXcassetsPath: URL?
                let imagesXcassetsPath: URL?
                let colorsXcassetsPath: URL?
                let fontsXcassetsPath: URL?
                let gifsXcassetsPath: URL?

                init(json: JSON) {
                    appIconXcassetsPath = json["app_icon_path"].fileURL
                    imagesXcassetsPath  = json["images_path"].fileURL
                    colorsXcassetsPath  = json["colors_path"].fileURL
                    fontsXcassetsPath   = json["fonts_path"].fileURL
                    gifsXcassetsPath    = json["gifs_path"].fileURL
                }
            }

            init(json: JSON) {
                input = Input(json: json["input"])
                output = Output(json: json["output"])
            }

        }

        let xcassets: Xcassets
        let templatePath: URL?
        let outputPath: URL?
        let isUseInPod: Bool

        init(json: JSON) {
            xcassets = Xcassets(json: json["xcassets"])
            templatePath = json["template_path"].fileURL
            outputPath = json["output_path"].fileURL
            isUseInPod = json["podspec"].exists()
        }
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



    let podspec: Podspec?
    let git: Git
    let asset: Asset
    let warn: Warn?
    let debug: Debug
    let message: Message

    init(json: JSON) throws {
        debug   = Debug(rawValue: json["debug"].stringValue) ?? .normal
        message = Message(json: json["message"])
        git     = Git(json: json["git"])
        warn    = Warn(json: json["warn"])
        asset   = Asset(json: json["asset"])
        if json["podspec"].exists() {
            let result = json["podspec"]
            podspec = Podspec(templatePath: result["template_path"].fileURL,
                              outputPath: result["output_path"].fileURL,
                              repo: Podspec.Repo(json: result["repo"]))
        } else {
            podspec = nil
        }
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
