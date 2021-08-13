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
import VariablesMaker

struct ImageXcassetsController: XcassetsControllerProtocol {
    
    let xcassets: Xcassets
    private let codeTemplate: ImageCodeTemplate?
    private var resources: [Xcassets.Image] { xcassets.images }
    private let logger = Logger(label: "image")
    
    init(xcassets: Xcassets) throws {
        self.xcassets = xcassets
        if let output = xcassets.template?.output {
            codeTemplate = ImageCodeTemplate(folder: try .init(path: output), logger: logger)
        } else {
            codeTemplate = nil
        }
    }
    
    func run() throws {
        try resources.forEach { try task(with: $0) }
        try codeTemplate?.createDefaultFiles()
    }
    
    func task(with resource: Xcassets.Image) throws {
        var reportRows = [XcassetsReport.Row]()
        let folder = try FilePath.Folder(path: resource.output)
        let formatter = NameFormatter(split: ["_dark@", "_dark.", "@3x.", "@2x.", "@1x.", "."])
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
        
        let names = try read(paths: resource.inputs, predicates: [.custom({ item -> Bool in
            guard item.type  == .file else {
                return false
            }
            
            if item.attributes.name.lowercased().hasSuffix(".svg") {
                return true
            }
            
            let file = FilePath.File(url: item.url)
            return try [.png, .jpeg, .pdf].contains(file.data().st.mimeType)
        })])
        .reduce([String: [FilePath]](), { (result, filePath) -> [String: [FilePath]] in
            var result = result
            let name = formatter.file(filePath.attributes.name)
            if var list = result[name] {
                list.append(filePath)
                result[name] = list
            } else {
                result[name] = [filePath]
            }
            return result
        })
        .compactMap({ (name, filePaths) -> String? in
            guard filePaths.isEmpty == false else {
                return nil
            }
            let filename = resource.prefix + name
            let imageset = try folder.create(folder: "\(filename).imageset")
            logger.info(.init(stringLiteral:"bundle: \(resource.bundle_name ?? "main"), name: \(filename)"))
            try filePaths.forEach { try $0.copy(into: imageset) }
            if let content = contents[name] {
                try content.replace(imageset.create(file: "Contents.json", data: nil))
            } else {
                let data = try conversion(files: filePaths, properties: resource.properties)
                try imageset.create(file: "Contents.json", data: data)
            }
            
            if resource.report != nil {
                let currentPath = try FilePath.Folder(path: "./").url.path
                reportRows.append(.init(variableName: .init(item: NameFormatter().variable(name)),
                                        inputs: .init(item: filePaths.map(\.url.path).map{ $0.st.deleting(prefix: currentPath) }),
                                        outputFolderName: .init(item: filename),
                                        outputFolderPath: .init(item: imageset.url.path.st.deleting(prefix: currentPath)),
                                        inputSize: .init(item: filePaths.map(\.attributes).map(\.size).reduce(0, {$0 + $1}))))
            }
            return name
        })
        
        try codeTemplate?.createListFile(names: names, in: resource)
        report(rows: reportRows, in: resource)
    }
    
}

extension ImageXcassetsController {
    
    func report(rows: [XcassetsReport.Row], in resource: Xcassets.Image) {
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

extension ImageXcassetsController {
    
    enum ImageContentType: String, Hashable {
        case none = "none"
        case scale1x = "1x"
        case scale2x = "2x"
        case scale3x = "3x"
    }
    
    enum AppearanceType: Int {
        case light = 1
        case dark  = 2
        
        var conversion: [String: Any]? {
            switch self {
            case .dark:  return ["appearance": "luminosity", "value": "dark"]
            case .light: return nil // ["appearance": "luminosity", "value": "light"]
            }
        }
        
    }
    
    class ImageContent {
        let appearance: AppearanceType
        var images: [ImageContentType: String] = [:]
        
        init(appearance: AppearanceType) {
            self.appearance = appearance
        }
        
        var conversion: [[String: Any]] {
            guard images.isEmpty == false else {
                return []
            }
            return [ImageContentType.scale1x,
                    ImageContentType.scale2x,
                    ImageContentType.scale3x].map { item -> [String: Any] in
                        var result: [String:  Any] = ["idiom": "universal",
                                                      "scale": item.rawValue]
                        result["filename"] = images[item]
                        result["appearances"] = appearance.conversion
                        return result
                    }
        }
    }
    
    func conversion(files: [FilePath], properties: Xcassets.Image.Properties) throws -> Data {
        var contents: [String: Any] = [:]
        contents["info"] = ["version": 1, "author": "xcode"]
        
        var propertiesDict = [String: Any]()
        if properties.preserves_vector_representation {
            propertiesDict["preserves-vector-representation"] = true
        }
        if properties.template_rendering_intent.isEmpty == false {
            propertiesDict["template-rendering-intent"] = properties.template_rendering_intent
        }
        if propertiesDict.isEmpty == false {
            contents["properties"] = propertiesDict
        }
        
        if files.count == 1,
           let filename = files.first?.attributes.name,
           ["@3x.", "@2x.", "@1x."].first(where: { filename.contains($0) }) == nil {
            contents["images"] = [["filename" : filename, "idiom" : "universal"]]
            return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        }
        
        let store = files
            .reduce([ImageContentType: [FilePath]]()) { result, file -> [ImageContentType: [FilePath]] in
                var result = result
                let name = file.attributes.name
                if name.contains("@3x.") {
                    result[.scale3x] = (result[.scale3x] ?? []) + [file]
                } else if name.contains("@2x.") {
                    result[.scale2x] = (result[.scale2x] ?? []) + [file]
                } else if name.contains("@1x.") {
                    result[.scale1x] = (result[.scale1x] ?? []) + [file]
                } else {
                    result[.none] = (result[.none] ?? []) + [file]
                }
                return result
            }
            .reduce([ImageContentType: [AppearanceType: FilePath]]()) { (result, item) -> [ImageContentType: [AppearanceType: FilePath]] in
                var  result = result
                
                result[item.key] = item.value.reduce([AppearanceType: FilePath]()) { element, file -> [AppearanceType: FilePath] in
                    var element = element
                    let name = file.attributes.name
                    if name.contains("_dark@") {
                        element[.dark] = file
                    } else if name.contains("_dark.") {
                        element[.dark] = file
                    } else {
                        element[.light] = file
                    }
                    return element
                }
                
                return result
            }
        
        
        func imageContentMaker(_ appearance: AppearanceType) -> ImageContent {
            let content = ImageContent(appearance: appearance)
            if let file = store[.scale1x]?[appearance] {
                content.images[.scale1x] = file.attributes.name
            }
            
            if let file = store[.scale2x]?[appearance] ?? store[.none]?[appearance] {
                content.images[.scale2x] = file.attributes.name
            }
            
            if let file = store[.scale3x]?[appearance] {
                content.images[.scale3x] = file.attributes.name
            }
            return content
        }
        
        
        contents["images"] = imageContentMaker(.light).conversion + imageContentMaker(.dark).conversion
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }
    
}
