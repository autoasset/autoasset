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

struct Count: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Word counter.")

    @Option(name: [.short, .customLong("input")], help: "输入: 资源文件夹路径")
    var inputFile: String

    @Option(name: [.short, .customLong("output")], help: "输出: xcassets路径")
    var outputFile: String

    //    @Flag(name: .shortAndLong, help: "Print status updates while counting.")
    //    var verbose: Bool

    func run() throws {
        //        if verbose {
        //            print("""
        //                Counting words in '\(inputFile)' \
        //                and writing the result into '\(outputFile)'.
        //                """)
        //        }

        let inputFilePath  = try FilePath(url: URL(fileURLWithPath: inputFile))
        let tempFilePath   = try FilePath(url: URL(fileURLWithPath: "./tempAutoasset"), type: .folder)
        let outputFilePath = try FilePath(url: URL(fileURLWithPath: outputFile), type: .folder)

        guard inputFilePath.type == .folder else {
            throw RuntimeError("inputFile 不能是文件, 只能是文件夹")
        }

        try tempFilePath.delete()
        try inputFilePath.copy(to: tempFilePath)
        let filePaths = try tempFilePath.subAllFilePaths().filter({ $0.type == .file })

        var imageFilePaths = [String: [FilePath]]()
        var gifFilePaths = [FilePath]()

        for item in filePaths {
            guard item.fileName.hasPrefix(".") == false else {
                continue
            }
            switch try item.data().st.mimeType {
            case .gif:
                gifFilePaths.append(item)
            default:
                guard let name = item.fileName.split(separator: "@").first?.split(separator: ".").first?.description else {
                    continue
                }
                if imageFilePaths[name] == nil {
                    imageFilePaths[name] = [item]
                } else {
                    imageFilePaths[name]?.append(item)
                }
            }
        }

        try outputFilePath.delete()
        try outputFilePath.create()

        let imageFolders = try imageFilePaths.map { key, value -> FilePath in
            let folder = try outputFilePath.create(folder: "\(key).imageset")
            var flag = false
            value.forEach { item in
                do {
                    try item.move(to: folder)
                } catch {
                    flag = true
                }
                if flag {
                    print("文件重复: \n\(value.map({ $0.url.path }))")
                }
            }
            return folder
        }

        try imageFolders.forEach { folder in
            let fileNames = try folder.subFilePaths().map({ $0.fileName })
            var contents: [String: Any] = ["info": ["version": 1, "author": "xcode"]]
            var list = [[String: String]]()
            do {
                var dict = ["idiom": "universal", "scale": "3x"]
                if let name = fileNames.first(where: { $0.contains("@3x.") }) {
                    dict["filename"] = name
                }
                list.append(dict)
            }
            do {
                var dict = ["idiom": "universal", "scale": "2x"]
                if let name = fileNames.first(where: { $0.contains("@2x.") }) {
                    dict["filename"] = name
                }
                list.append(dict)
            }
            do {
                var dict = ["idiom": "universal", "scale": "1x"]
                if let name = fileNames.first(where: { $0.contains("@2x.") == false && $0.contains("@3x.") == false }) {
                    dict["filename"] = name
                }
                list.append(dict)
            }
            contents["images"] = list
            let data = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted])
            try data.write(to:  folder.url.appendingPathComponent("Contents.json"))
        }

        try tempFilePath.delete()
    }
}



struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

//Count.main()
var count = Count()
count.inputFile  = "./UI/"
count.outputFile = "./image.xcassets"
try! count.run()
