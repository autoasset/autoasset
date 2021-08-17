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

struct ColorXcassetsController: XcassetsControllerProtocol {
    
    let xcassets: Xcassets
    var resources: [Xcassets.Color] { xcassets.colors }
    private let codeTemplate: ColorCodeTemplate?
    private let logger = Logger(label: "colors")
    
    init(xcassets: Xcassets) throws {
        self.xcassets = xcassets
        if let output = xcassets.template?.output {
            codeTemplate = ColorCodeTemplate(folder: try .init(path: output), logger: logger)
        } else {
            codeTemplate = nil
        }
    }
    
    func run() throws {
        try resources.forEach { try task(with: $0) }
        try codeTemplate?.createDefaultFiles()
    }
    
    func task(with resource: Xcassets.Color) throws {
        var unique = Set<StemColor>()
        let folder = try FilePath.Folder(path: resource.output)
        let colors = try read(paths: resource.inputs, predicates: [.skipsHiddenFiles, .custom({ $0.type == .file })])
            .map { FilePath.File(url: $0.url) }
            .map { try JSON(data: $0.data()).arrayValue }
            .joined()
            .compactMap { Color(json: $0) }
            .filter({ unique.insert($0.light).inserted })
            .map({ (color: $0, try conversion(color: $0, resource: resource)) })
            .map({ (color, data) -> Color in
                let name = color.light.hexString(.digits6, prefix: .none)
                let imageset = try folder.create(folder: "\(name).colorset")
                logger.info(.init(stringLiteral: imageset.attributes.name))
                try imageset.create(file: "Contents.json", data: data)
                return color
            })
        try codeTemplate?.createListFile(colors: colors)
    }
    
}

extension ColorXcassetsController {
    
    func conversion(color: Color, resource: Xcassets.Color) throws -> Data {
        var colors = [[String: Any]]()
        
        if color.light == color.dark {
            var element = [String: Any]()
            element["color-space"] = resource.space
            element["components"] = self.components(color.light)
            colors.append(["idiom": "universal", "color": element])
        } else {
            var element_light = [String: Any]()
            element_light["color-space"] = resource.space
            element_light["components"] = self.components(color.light)
            
            var element_dark = [String: Any]()
            element_dark["color-space"] = resource.space
            element_dark["components"] = self.components(color.dark)
            
            colors.append(["idiom": "universal", "color": element_light])
            colors.append(["appearances": [["appearance": "luminosity", "value": "light"]], "idiom": "universal", "color": element_light])
            colors.append(["appearances": [["appearance": "luminosity", "value": "dark"]], "idiom": "universal", "color": element_dark])
            
        }
        
        let contents: [String : Any] = ["colors": colors,
                                        "info": ["version": 1, "author": "xcode"],
                                        "properties": ["localizable": true]]
        
        return try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    }
    
    func components(_ color: StemColor) -> [String: String] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.formatWidth = 3
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        let hex = color.hexString(.digits6, prefix: .none).map(\.description)
        return ["alpha": formatter.string(from: .init(value: color.alpha))!,
                "blue" : "0x\(hex[4...5].joined().uppercased())",
                "green": "0x\(hex[2...3].joined().uppercased())",
                "red"  : "0x\(hex[0...1].joined().uppercased())"]
    }
    
}
