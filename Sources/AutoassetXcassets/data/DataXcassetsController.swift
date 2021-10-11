// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Stem
import AutoassetModels
import Logging
import CSV
import VariablesMaker

class DataXcassetsController: XcassetsControllerProtocol {
    
    let resources: [Xcassets.Data]
    private let codeTemplate: DataCodeTemplate?
    let xcassets: Xcassets
    let logger: Logger
    
    init(named: DataCodeTemplate.Named, resources: [Xcassets.Data], xcassets: Xcassets) throws {
        
        self.xcassets = xcassets
        self.resources = resources
        self.logger = Logger(label: named.rawValue)

        if let output = xcassets.template?.output {
            codeTemplate = DataCodeTemplate(named: named, folder: try .init(path: output), logger: logger)
        } else {
            codeTemplate = nil
        }
        
    }
    
    func run() throws {
        try resources.forEach { try task(with: $0) }
        try codeTemplate?.createDefaultFiles()
    }
    
    func task(with resource: Xcassets.Data) throws {
        var reportRows = [XcassetsReport.Row]()
        let contents = try read(paths: [resource.contents].compactMap{ $0 }, predicates: [.custom{ $0.attributes.name.hasSuffix(".json") }])
            .map({ FilePath.File(url: $0.url) })
            .reduce([String: FilePath.File](), { (result, filePath) -> [String: FilePath.File] in
                guard let name = filePath.attributes.name.split(separator: ".").first?.description else {
                    return result
                }
                var result = result
                result[name] = filePath
                return result
            })
        
        var unique = Set<String>()
        let folder = try FilePath.Folder(path: resource.output)
        let currentPath = try FilePath.Folder(path: "./").url.path + "/"
        let names = try read(paths: resource.inputs, predicates: [.skipsHiddenFiles, .custom({ $0.type == .file })])
            .filter({ unique.insert($0.attributes.name).inserted })
            .map({ FilePath.File(url: $0.url) })
            .map({ file -> String in
                let filename = file.attributes.name
                let name = filename.split(separator: ".").first!.description
                let imageset = try folder.create(folder: "\(resource.prefix)\(name).dataset")
                logger.info(.init(stringLiteral: filename))
                try file.copy(into: imageset)
                if let content = contents[name] {
                    try content.replace(imageset.create(file: "Contents.json", data: nil))
                } else {
                    let data = try conversion(name: filename)
                    try imageset.create(file: "Contents.json", data: data)
                }
                
                if resource.report != nil {
                    reportRows.append(.init(variableName: .init(item: NameFormatter().variable(name)),
                                            inputs: .init(item: [file.url.path.st.deleting(prefix: currentPath)]),
                                            outputFolderName: .init(item: filename),
                                            outputFolderPath: .init(item: imageset.url.path.st.deleting(prefix: currentPath)),
                                            inputSize: .init(item: file.attributes.size)))
                }
                
                return name
            })
        try codeTemplate?.createListFile(names: names, in: resource)
        report(rows: reportRows, in: resource)
    }
}

extension DataXcassetsController {
    
    func report(rows: [XcassetsReport.Row], in resource: Xcassets.Data) {
        guard let output = resource.report else {
            return
        }
        do {
            let file = try FilePath.File(path: output)
            try? file.delete()
            try file.create(with: CSV(rows: rows.sorted(by: { $0.inputSize.item > $1.inputSize.item})).file())
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }

}

extension DataXcassetsController {
    
    func conversion(name: String) throws -> Data {
        var contents: [String: Any] = [:]
        let info: [String: Any] = ["version": 1, "author": "xcode"]
        contents["info"] = info
        contents["data"] = [["filename" : name,
                             "idiom" : "universal"]]
        
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }
    
}
