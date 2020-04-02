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
       return URL(fileURLWithPath: stringValue)
    }
}

struct Config {

    struct Asset {
        let path: URL?
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

    let podspec: Podspec
    let xcassets: Xcassets
    let asset: Asset

    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        let json = try JSON(data: data)
        do {
            let result = json["asset"]
            asset = Asset(path: result["path"].fileURL)
        }
        do {
            let result = json["podspec"]
            podspec = Podspec(templatePath: result["template_path"].fileURL,
                              outputPath: result["output_path"].fileURL)
        }
        do {
            let result = json["xcassets"]
            xcassets = Xcassets(input: Xcassets.Input(appIconPath: result["app_icon_path"].fileURL,
                                                      imagesPath: result["images_path"].fileURL,
                                                      colorsPath: result["colors_path"].fileURL,
                                                      fontsPath: result["fonts_path"].fileURL,
                                                      gifsPath: result["gifs_path"].fileURL),
                                output: Xcassets.Output(appIconXcassetsPath: result["app_icon_xcassets_path"].fileURL,
                                                        imagesXcassetsPath: result["images_xcassets_path"].fileURL,
                                                        colorsXcassetsPath: result["colors_xcassets_path"].fileURL,
                                                        fontsXcassetsPath: result["fonts_xcassets_path"].fileURL,
                                                        gifsXcassetsPath: result["gifs_xcassets_path"].fileURL))
        }

    }
}
