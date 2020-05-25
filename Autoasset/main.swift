//
//  main.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/25.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//
import Foundation
import ArgumentParser
import Stem

struct Main: ParsableCommand {

    static let configuration = CommandConfiguration(version: Autoasset.version)
    @Option(name: [.short, .customLong("config")], help: "配置")
    var config: String

    func run() throws {
        do {
            let config = try Config(url: FilePath(path: self.config, type: .file).url)
            try Autoasset(config: config).start()
        } catch {
            if let error = error as? RunError {
                RunPrint(error.message)
            } else {
                RunPrint(error.localizedDescription)
            }
        }
    }
}

extension Main {

}

extension CharacterSet {
    func allUnicodeScalars() -> [UnicodeScalar] {
        var result: [UnicodeScalar] = []
        for plane in Unicode.UTF8.CodeUnit.min...16 where self.hasMember(inPlane: plane) {
            for unicode in Unicode.UTF32.CodeUnit(plane) << 16 ..< Unicode.UTF32.CodeUnit(plane + 1) << 16 {
                if let uniChar = UnicodeScalar(unicode), self.contains(uniChar) {
                    result.append(uniChar)
                }
            }
        }
        return result
    }
}

//Main.main()



let icon = IconFont(from: URL(fileURLWithPath: "/Users/linhey/Downloads/font_j2y0smuu1vs/iconfont.ttf"))!
RunPrint(icon.font.st.glyphsForCharacters.description)
