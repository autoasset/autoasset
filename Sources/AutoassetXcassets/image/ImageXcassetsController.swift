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

class ImageXcassetsController: XcassetsControllerProtocol {
    
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
    
    private class Pip {
        
        let resource: Xcassets.Image
        var imagesets: [String: [FilePath.File]] = [:]
        var contents: [String : FilePath.File] = [:]

        init(resource: Xcassets.Image) {
            self.resource = resource
        }
        
    }
    
    func run() throws -> [Validate] {
        let pips = try resources
            .map(Pip.init(resource:))
            .map { pip -> Pip in
                try setImageSets(to: pip)
                try setContents(to: pip)
                return pip
            }
        
        let validates = try validate(pips: pips)
        if validates.contains(where: { $0.level == .error }) {
            return validates
        }
        
        try pips.forEach { try task(pip: $0) }
        try codeTemplate?.createDefaultFiles()
        
        return validates
    }
        
}

private extension ImageXcassetsController {
    
    /// 资源文件合法性检测
    private func validate(pips: [Pip]) throws -> [Validate] {
        var valiates = [Validate]()
        
        let rootPath = try FilePath.Folder(path: "./").url.path

        /// duplicate_resource_files
        do {
            let dict = pips
                .map(\.imagesets)
                .reduce([String: [[FilePath.File]]]()) { (result, imagesets) -> [String: [[FilePath.File]]] in
                 var result = result
                 imagesets.forEach { item in
                     if result[item.key] != nil {
                         result[item.key]?.append(item.value)
                     } else {
                         result[item.key] = [item.value]
                     }
                 }
                 return result
            }.filter { item in
                return item.value.count > 1
            }.mapValues { fileGroup in
                fileGroup.reduce([FilePath.File](), { $0 + $1 })
            }
            
            if dict.isEmpty == false {
                let message = dict.map { item in
                    [item.key]
                    + item.value
                        .map(\.url.path)
                        .map({ $0.st.deleting(prefix: rootPath) })
                        .map({ "  - \($0)" })
                }
                    .map { $0.joined(separator: "\n") }
                    .joined(separator: "\n")
                valiates.append(.duplicate_resource_files(message))
            }
        }
        
        /// content_file_not_used
        do {
            var used = [URL: FilePath.File]()
            var unused = [URL: FilePath.File]()
            
            for pip in pips {
                for content in pip.contents {
                    guard used[content.value.url] == nil else {
                        continue
                    }
                    
                    if pip.imagesets[content.key] != nil {
                        used[content.value.url] = content.value
                        unused[content.value.url] = nil
                    } else {
                        unused[content.value.url] = content.value
                    }
                }
            }
            
            used = [:]
            
            let message = unused
                .map(\.value.url.path)
                .map({ $0.st.deleting(prefix: rootPath) })
                .enumerated()
                .map({ "\($0.offset + 1). \($0.element)" })
                .joined(separator: "\n")

            valiates.append(.duplicate_resource_files(message))
        }
        
        return valiates
    }

}

private extension ImageXcassetsController {
    
    /// 待处理图片文件
    private func setImageSets(to pip: Pip) throws {
        let formatter = NameFormatter(split: ["_dark@", "_dark.", "@3x.", "@2x.", "@1x.", "."])
        
        /// 搜寻 png / jpeg / pdf / svg 数据格式文件
        let imageFiles = try read(paths: pip.resource.inputs, predicates: [.custom({ item -> Bool in
            guard item.type  == .file else {
                return false
            }
            
            if item.attributes.name.lowercased().hasSuffix(".svg") {
                return true
            }
            
            let file = FilePath.File(url: item.url)
            return try [.png, .jpeg, .pdf].contains(file.data().st.mimeType)
        })]).compactMap({ $0.asFile() })
        
        /// 同名文件集合, @1x, @2x, @3x 暗色模式等图片作为一个集合
        pip.imagesets = imageFiles
            .dictionary(key: { formatter.file($0.attributes.name) }, value: \.self)
            .reduce([String: [FilePath.File]]()) { (result, item) -> [String: [FilePath.File]] in
                var result = result
                if var list = result[item.key] {
                    list.append(item.value)
                    result[item.key] = list
                } else {
                    result[item.key] = [item.value]
                }
                return result
            }
    }
    
    /// 自定义 contents 文件
    private func setContents(to pip: Pip) throws {
        pip.contents = try read(paths: [pip.resource.contents].compactMap{ $0 }, predicates: [.custom{ $0.attributes.name.hasSuffix(".json") }])
            .map({ FilePath.File(url: $0.url) })
            .reduce([String: FilePath.File](), { (result, filePath) -> [String: FilePath.File] in
                guard let name = filePath.attributes.name.split(separator: ".").first?.description else {
                    return result
                }
                var result = result
                result[name] = filePath
                return result
            })
    }
    
    private func task(pip: Pip) throws {
        var reportRows = [XcassetsReport.Row]()
        
        let resource = pip.resource
        let folder = try FilePath.Folder(path: resource.output)
                
        for (name, files) in pip.imagesets {
            let filename = resource.prefix + name
            let imageset = try folder.create(folder: "\(filename).imageset")
            logger.info(.init(stringLiteral:"bundle: \(resource.bundle_name ?? "main"), name: \(filename)"))
            try files.forEach { try $0.copy(into: imageset) }
            if let content = pip.contents[name] {
                try content.replace(imageset.create(file: "Contents.json", data: nil))
            } else {
                let data = try conversion(files: files, properties: resource.properties)
                try imageset.create(file: "Contents.json", data: data)
            }
            
            if resource.report != nil {
                let currentPath = try FilePath.Folder(path: "./").url.path
                reportRows.append(.init(variableName: .init(item: NameFormatter().variable(name)),
                                        inputs: .init(item: files.map(\.url.path).map{ $0.st.deleting(prefix: currentPath) }),
                                        outputFolderName: .init(item: filename),
                                        outputFolderPath: .init(item: imageset.url.path.st.deleting(prefix: currentPath)),
                                        inputSize: .init(item: files.map(\.attributes).map(\.size).reduce(0, {$0 + $1}))))
            }
        }
        
        try codeTemplate?.createListFile(names: Array(pip.imagesets.keys), in: resource)
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
    
    func conversion(files: [FilePath.File], properties: Xcassets.Image.Properties) throws -> Data {
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
            .reduce([ImageContentType: [FilePath.File]]()) { result, file -> [ImageContentType: [FilePath.File]] in
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
            .reduce([ImageContentType: [AppearanceType: FilePath.File]]()) { (result, item) -> [ImageContentType: [AppearanceType: FilePath.File]] in
                var  result = result
                
                result[item.key] = item.value.reduce([AppearanceType: FilePath.File]()) { element, file -> [AppearanceType: FilePath.File] in
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
