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
import StemCrossPlatform
import AutoassetModels
import Logging
import CSV

class DataXcassetsController: XcassetsControllerProtocol {
    
    enum Named: String {
        case data = "data"
        case gifs = "gifs"
        
        var className: String {
            switch self {
            case .data: return "Data"
            case .gifs: return "GIF"
            }
        }
    }
    
    let model: Config
    let named: Named
    let resources: [Xcassets.Data]
    var xcassets: Xcassets { model.xcassets }
    lazy var logger = Logger(label: named.rawValue)
    
    init(model: Config, named: Named, resources: [Xcassets.Data]) {
        self.model = model
        self.named = named
        self.resources = resources
    }
    
    func run() throws {
        setDefaultFiles()
        try resources.forEach { try task(with: $0) }
    }
    
    func task(with resource: Xcassets.Data) throws {
        var reportRows = [XcassetsReport.Row]()
        let contents = try read(paths: [resource.contents].compactMap{ $0 }, predicates: [.custom{ $0.attributes.name.hasSuffix(".json") }])
            .reduce([String: FilePath](), { (result, filePath) -> [String: FilePath] in
                guard let name = filePath.attributes.name.split(separator: ".").first?.description else {
                    return result
                }
                var result = result
                result[name] = filePath
                return result
            })
        
        var unique = Set<String>()
        let folder = try FilePath(path: resource.output, type: .folder)
        let currentPath = try FilePath(path: "./").path + "/"
        let names = try read(paths: resource.inputs, predicates: [.skipsHiddenFiles, .custom({ $0.type == .file })])
            .filter({ unique.insert($0.attributes.name).inserted })
            .map({ file -> String in
                let filename = file.attributes.name
                let name = filename.split(separator: ".").first!.description
                let imageset = try folder.create(folder: "\(resource.prefix)\(name).dataset")
                logger.info(.init(stringLiteral: filename))
                try file.copy(to: imageset)
                if let content = contents[name] {
                    let target = try FilePath(url: imageset.url.appendingPathComponent("Contents.json", isDirectory: false))
                    try content.copy(to: target)
                } else {
                    let data = try conversion(name: filename)
                    try imageset.create(file: "Contents.json", data: data)
                }
                
                if resource.report != nil {
                    reportRows.append(.init(variableName: .init(item: NameFormatter().variableName(name)),
                                            inputs: .init(item: [file.path.st.deleting(prefix: currentPath)]),
                                            outputFolderName: .init(item: filename),
                                            outputFolderPath: .init(item: imageset.path.st.deleting(prefix: currentPath)),
                                            inputSize: .init(item: file.attributes.size ?? 0)))
                }
                
                return name
            })
        
        setTemplateList(names: names, in: resource)
        report(rows: reportRows, in: resource)
    }
}

extension DataXcassetsController {
    
    func report(rows: [XcassetsReport.Row], in resource: Xcassets.Data) {
        guard let output = resource.report else {
            return
        }
        do {
            let file = try FilePath(path: output, type: .file)
            try? file.delete()
            try file.create(with: CSV(rows: rows.sorted(by: { $0.inputSize.item > $1.inputSize.item})).file())
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func setDefaultFiles() {
        guard let output = xcassets.template?.output else {
            return
        }
        do {
            let folder = try FilePath(path: output, type: .folder)
            try folder.create(file: "autoasset_\(named.rawValue)_protocol.swift", data: template_protocol().data(using: .utf8))
            try folder.create(file: "autoasset_\(named.rawValue).swift", data: template_core().data(using: .utf8))
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func setTemplateList(names: [String], in resource: Xcassets.Data) {
        guard let output = xcassets.template?.output else {
            return
        }
        let formatter = NameFormatter()
        let bundle_name = resource.bundle_name == nil ? "nil" : "\"\(resource.bundle_name!)\""
        let list = names.map({ item -> String in
            return "   static var \(formatter.variableName(item)): Self { self.init(named: \"\(resource.prefix)\(item)\", in: \(bundle_name)) }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAsset\(named.className)Protocol {\n\(list)\n}"
        
        do {
            let folder = try FilePath(path: output, type: .folder)
            try folder.create(file: "autoasset_\(named.rawValue)_list_\(resource.bundle_name ?? "main").swift", data: str.data(using: .utf8))
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func template_protocol() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif

        public protocol AutoAsset\(named.className)Protocol {
            init(named: String, in bundle: String?)
            func value() -> Data
        }
        """
    }
    
    func template_core() -> String {
        """
        #if canImport(UIKit)
        import UIKit
        #elseif canImport(AppKit)
        import AppKit
        #endif

        class AutoAsset\(named.className): AutoAsset\(named.className)Protocol {

            let named: String
            let bundle: String?
            
            required init(named: String, in bundle: String?) {
                self.named = named
                self.bundle = bundle
            }
            
            @available(iOS 9.0, macOS 10.11, tvOS 6.0, watchOS 2.0, *)
            public func value() -> Foundation.Data {
                if let bundleName = bundle,
                   let bundle = Bundle(identifier: bundleName),
                   let data = NSDataAsset(name: named, bundle: bundle)?.data {
                    return data
                } else if let data = NSDataAsset(name: named, bundle: Bundle.main)?.data {
                    return data
                } else {
                    assertionFailure("can't find data: \\(named) in bundle: \\(bundle ?? "main")")
                    return Foundation.Data()
                }
            }
        }
        """
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
