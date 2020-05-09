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

class TemplateInputModel {
    let outputPath: URL
    let template: String

    init?(json: JSON, onlyOutput: Bool = false) {
        guard let output = json["output_path"].fileURL else {
            return nil
        }

        self.outputPath = output

        if onlyOutput {
            self.template = ""
            return
        }

        if let template = json["template"].string {
            self.template = template
            return
        }

        guard let path = json["template_path"].url?.path, let template = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        self.template = template
    }
}

protocol TemplateInputProtocol {
    var templateInputModel: TemplateInputModel? { get }
}

extension TemplateInputProtocol {

    var template: String? { templateInputModel?.template }
    var outputPath: URL? { templateInputModel?.outputPath }

}

struct Config {

    enum Mode: String {
        case normal
        case local
        case pod_with_branch
        case test_message
        case test_podspec
        case test_warn
    }

    struct ModeVariables {
        let version: String

        init(json: JSON) {
            version = json["version"].stringValue
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

    struct Asset: TemplateInputProtocol {

        struct Xcassets {

            let input: Input
            let output: Output

            struct Input {
                let appIconPath: URL?
                let imagesPath: URL?
                let imagesContentsPath: URL?
                let colorsPath: URL?
                let fontsPath: URL?
                let gifsPath: URL?

                init(json: JSON) {
                    appIconPath        = json["app_icon_path"].fileURL
                    imagesContentsPath = json["images_contents_path"].fileURL
                    imagesPath         = json["images_path"].fileURL
                    colorsPath         = json["colors_path"].fileURL
                    fontsPath          = json["fonts_path"].fileURL
                    gifsPath           = json["gifs_path"].fileURL
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

        let templateInputModel: TemplateInputModel?
        let xcassets: Xcassets
        let isUseInPod: Bool

        init(json: JSON) {
            xcassets = Xcassets(json: json["xcassets"])
            templateInputModel = TemplateInputModel(json: json)
            isUseInPod = json["podspec"].exists()
        }
    }

    struct Podspec: TemplateInputProtocol {

        enum Mode: String {
            case tag
            case branch
        }

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

        let templateInputModel: TemplateInputModel?
        let repo: Repo?

        init(json: JSON) {
            templateInputModel = TemplateInputModel(json: json)
            repo = Repo(json: json["repo"])
        }
    }

    class Message: TemplateInputModel { }
    class Warn: TemplateInputModel { }


    let podspec: Podspec?
    let git: Git
    let asset: Asset
    let mode: Mode
    let modeVariables: ModeVariables
    let warn: Warn?
    let message: Message?

    init(json: JSON) throws {
        modeVariables = ModeVariables(json: json["mode_variables"])
        mode    = Mode(rawValue: json["mode"].stringValue) ?? .normal
        podspec = Podspec(json: json["podspec"])
        message = Message(json: json["message"])
        git     = Git(json: json["git"])
        warn    = Warn(json: json["warn"], onlyOutput: true)
        asset   = Asset(json: json["asset"])
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
