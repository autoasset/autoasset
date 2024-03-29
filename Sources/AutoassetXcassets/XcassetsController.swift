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
import Logging
import Stem
import VariablesMaker
import AutoassetModels
import AutoassetiOSCode

public struct XcassetsController {
    
    private let xcassets: Xcassets
    private let logger = Logger(label: "xcassets")

    public init(model: Xcassets, variables: Variables) throws {
        let variablesMaker = VariablesMaker(variables)
        self.xcassets = try Xcassets(
            colors: model.colors.map({ item -> Xcassets.Color in
                return try .init(inputs: item.inputs.map(variablesMaker.textMaker(_:)),
                                 output: variablesMaker.textMaker(item.output),
                                 prefix: variablesMaker.textMaker(item.prefix),
                                 suffix: variablesMaker.textMaker(item.suffix),
                                 space: variablesMaker.textMaker(item.space))
            }),
            images: model.images.map({ item -> Xcassets.Image in
                return try .init(inputs: item.inputs.map(variablesMaker.textMaker(_:)),
                                 output: variablesMaker.textMaker(item.output),
                                 report: variablesMaker.textMaker(item.report),
                                 prefix: variablesMaker.textMaker(item.prefix),
                                 contents: variablesMaker.textMaker(item.contents),
                                 properties: item.properties,
                                 bundle_name: variablesMaker.textMaker(item.bundle_name))
            }),
            gifs: model.gifs.map({ item -> Xcassets.Data in
                return try .init(inputs: item.inputs.map(variablesMaker.textMaker(_:)),
                                 output: variablesMaker.textMaker(item.output),
                                 report: variablesMaker.textMaker(item.report),
                                 prefix: variablesMaker.textMaker(item.prefix),
                                 contents: variablesMaker.textMaker(item.contents),
                                 properties: item.properties,
                                 bundle_name: variablesMaker.textMaker(item.bundle_name))
            }),
            datas: model.datas.map({ item -> Xcassets.Data in
                return try .init(inputs: item.inputs.map(variablesMaker.textMaker(_:)),
                                 output: variablesMaker.textMaker(item.output),
                                 report: variablesMaker.textMaker(item.report),
                                 prefix: variablesMaker.textMaker(item.prefix),
                                 contents: variablesMaker.textMaker(item.contents),
                                 properties: item.properties,
                                 bundle_name: variablesMaker.textMaker(item.bundle_name))
            }),
            template: Xcassets.Template(output: variablesMaker.textMaker(model.template?.output)))
    }
    
    public func run() throws {
        if let output = xcassets.template?.output {
            try iOSCodeForBundle(folder: try .init(path: output), logger: logger).createDefaultFiles()
        }
    
        let colorController = try ColorXcassetsController(xcassets: xcassets)
        try colorController.run()
        
        let imageController = try ImageXcassetsController(xcassets: xcassets)
        try imageController.run()
        
        let gifsController = try DataXcassetsController(named: .gifs, resources: xcassets.gifs, xcassets: xcassets)
        try gifsController.run()
        
        let dataController = try DataXcassetsController(named: .data, resources: xcassets.datas, xcassets: xcassets)
        try dataController.run()
    }
    
}
