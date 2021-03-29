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

class ImageXcassetsController: XcassetsControllerProtocol {
    
    let model: Config
    var xcassets: Xcassets { model.xcassets }
    var resources: [Xcassets.Image] { xcassets.images }
    let logger = Logger(label: "image")

    init(model: Config) {
        self.model = model
    }
    
    func run() throws {
        setDefaultFiles()
        try resources.forEach { try task(with: $0) }
    }
    
    func task(with resource: Xcassets.Image) throws {
        var reportRows = [XcassetsReport.Row]()
        let folder = try FilePath(path: resource.output, type: .folder)
        let formatter = NameFormatter(split: ["_dark@", "_dark.", "@3x.", "@2x.", "@1x.", "."])
        let contents = try read(paths: [resource.contents].compactMap{ $0 }, predicates: [.custom{ $0.attributes.name.hasSuffix(".json") }])
            .reduce([String: FilePath](), { (result, filePath) -> [String: FilePath] in
                guard let name = filePath.attributes.name.split(separator: ".").first?.description else {
                    return result
                }
                var result = result
                result[name] = filePath
                return result
            })
        
        let names = try read(paths: resource.inputs,
                 predicates: [.custom({ item -> Bool in
                    if item.attributes.name.lowercased().hasSuffix(".svg") {
                        return true
                    }
                    return try [.png, .jpeg, .pdf].contains(item.data().st.mimeType)
                 })])
            .reduce([String: [FilePath]](), { (result, filePath) -> [String: [FilePath]] in
                var result = result
                let name = formatter.fileName(filePath.attributes.name)
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
                try filePaths.forEach { try $0.copy(to: imageset) }
                if let content = contents[name] {
                    let target = try FilePath(url: imageset.url.appendingPathComponent("Contents.json", isDirectory: false))
                    try content.copy(to: target)
                } else {
                    let data = try conversion(files: filePaths)
                    try imageset.create(file: "Contents.json", data: data)
                }
                
                if resource.report != nil {
                    let currentPath = try FilePath(path: "./").path + "/"
                    reportRows.append(.init(variableName: .init(item: NameFormatter().variableName(name)),
                                            inputs: .init(item: filePaths.map(\.path).map{ $0.st.deleting(prefix: currentPath) }),
                                            outputFolderName: .init(item: filename),
                                            outputFolderPath: .init(item: imageset.path.st.deleting(prefix: currentPath)),
                                            inputSize: .init(item: filePaths.map(\.attributes).compactMap(\.size).reduce(0, {$0 + $1}))))
                }
                return name
            })
        
        setTemplateList(names: names, in: resource)
        report(rows: reportRows, in: resource)
    }
    
}

extension ImageXcassetsController {

    func report(rows: [XcassetsReport.Row], in resource: Xcassets.Image) {
        guard let output = resource.report else {
            return
        }
        do {
            let file = try FilePath(path: output, type: .file)
            try? file.delete()
            try file.create(with: CSV(rows: rows).file())
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
}

extension ImageXcassetsController {
    
    func setDefaultFiles() {
        guard let output = xcassets.template?.output else {
            return
        }
        do {
            let folder = try FilePath(path: output, type: .folder)
            try folder.create(file: "autoasset_image_protocol.swift", data: template_protocol().data(using: .utf8))
            try folder.create(file: "autoasset_image.swift", data: template_core().data(using: .utf8))
        } catch {
            logger.error(.init(stringLiteral: error.localizedDescription))
        }
    }
    
    func setTemplateList(names: [String], in resource: Xcassets.Image) {
        guard let output = xcassets.template?.output else {
            return
        }
        let bundle_name = resource.bundle_name == nil ? "nil" : "\"\(resource.bundle_name!)\""
        let list = names.map({ item -> String in
            return "   static var \(NameFormatter().variableName(item)): Self { self.init(named: \"\(resource.prefix)\(item)\", in: \(bundle_name)) }"
        }).joined(separator: "\n")
        
        let str = "public extension AutoAssetImageProtocol {\n\(list)\n}"
        do {
            let folder = try FilePath(path: output, type: .folder)
            try folder.create(file: "autoasset_image_list_\(resource.bundle_name ?? "main").swift", data: str.data(using: .utf8))
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
        #if canImport(SwiftUI)
        import SwiftUI
        #endif

        public protocol AutoAssetImageProtocol {
            init(named: String, in bundle: String?)
            #if canImport(UIKit)
            func value() -> UIImage
            #elseif canImport(AppKit)
            func value() -> NSImage
            #endif
            #if canImport(SwiftUI)
            @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
            func value() -> SwiftUI.Image
            #endif
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
        #if canImport(SwiftUI)
        import SwiftUI
        #endif

        class AutoAssetImage: AutoAssetImageProtocol {
            
            let named: String
            let bundle: String?
            
            required init(named: String, in bundle: String?) {
                self.named = named
                self.bundle = bundle
            }
            
            #if canImport(UIKit)
            func value() -> UIImage {
                if let bundleName = bundle,
                   let bundle = Bundle(identifier: bundleName),
                   let image = UIImage(named: named, in: bundle, compatibleWith: nil) {
                    return image
                } else if let image = UIImage(named: named) {
                    return image
                } else {
                    assertionFailure("can't find image: \\(named) in bundle: \\(bundle ?? "main")")
                    return UIImage()
                }
            }
            
            #elseif canImport(AppKit)
            func value() -> NSImage {
                return .init(imageLiteralResourceName: named)
            }
            #endif
            
            #if canImport(SwiftUI)
            @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
            func value() -> SwiftUI.Image {
                #if canImport(UIKit)
                return SwiftUI.Image(uiImage: value())
                #elseif canImport(AppKit)
                return SwiftUI.Image(nsImage: value())
                #else
                return SwiftUI.Image("")
                #endif
            }
            #endif
            
        }
        """
    }
    
}

extension ImageXcassetsController {
    
    enum ImageContentType: Int, Hashable {
        case none = 40
        case scale1x = 10
        case scale2x = 20
        case scale3x = 30
    }
    
    enum AppearanceType: Int {
        case light = 1
        case dark  = 2
    }
    
    func conversion(files: [FilePath]) throws -> Data {
        var appearance_light = [String: Any]()
        appearance_light["appearance"] = "luminosity"
        appearance_light["value"] = "light"
        
        var appearance_dark = [String: Any]()
        appearance_dark["appearance"] = "luminosity"
        appearance_dark["value"] = "dark"
        
        let pdf_properties: [String: Any] = ["compression-type": "automatic", "preserves-vector-representation": true]
        
        var contents: [String: Any] = [:]
        let info: [String: Any] = ["version": 1, "author": "xcode"]
        contents["info"] = info
        
        let pdfs = try files.filter { try $0.data().st.mimeType == .pdf }
        if pdfs.isEmpty == false {
            contents["properties"] = pdf_properties
        }
        
        var images = [(appearances: [String: Any]?, filename: String?, scale: String)]()
        
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
        
        if let file = store[.scale1x]?[.light] {
            images.append((appearances: nil, filename: file.attributes.name, scale: "1x"))
        } else {
            images.append((appearances: nil, filename: nil, scale: "1x"))
        }
        
        if let file = store[.scale2x]?[.light] ?? store[.none]?[.light] {
            images.append((appearances: nil, filename: file.attributes.name, scale: "2x"))
        } else {
            images.append((appearances: nil, filename: nil, scale: "2x"))
        }
        
        if let file = store[.scale3x]?[.light] {
            images.append((appearances: nil, filename: file.attributes.name, scale: "3x"))
        } else {
            images.append((appearances: nil, filename: nil, scale: "3x"))
        }
        
        if let file = store[.scale1x]?[.dark] {
            images.append((appearances: appearance_dark, filename: file.attributes.name, scale: "1x"))
        } else {
            images.append((appearances: appearance_dark, filename: nil, scale: "1x"))
        }
        
        if let file = store[.scale2x]?[.dark] ?? store[.none]?[.dark] {
            images.append((appearances: appearance_dark, filename: file.attributes.name, scale: "2x"))
        } else {
            images.append((appearances: appearance_dark, filename: nil, scale: "2x"))
        }
        
        if let file = store[.scale3x]?[.dark] {
            images.append((appearances: appearance_dark, filename: file.attributes.name, scale: "3x"))
        } else {
            images.append((appearances: appearance_dark, filename: nil, scale: "3x"))
        }
        
        let imagesContents = images.map { item -> [String: Any] in
            var result = [String:  Any]()
            result["appearances"] = item.appearances
            result["filename"] = item.filename
            result["idiom"] = "universal"
            result["scale"] = item.scale
            return result
        }
        
        contents["images"] = imagesContents
        
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }
    
}
