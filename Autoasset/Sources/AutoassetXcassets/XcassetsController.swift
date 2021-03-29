//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

import Foundation
import StemCrossPlatform
import AutoassetModels
import Logging

public struct XcassetsController {
    
    let model: Config
    var xcassets: Xcassets { model.xcassets }

    public init(model: Config) {
        self.model = model
    }
    
    public func run() throws {
        let colorController = ColorXcassetsController(model: model)
        try colorController.run()
        
        let imageController = ImageXcassetsController(model: model)
        try imageController.run()
        
        let gifsController = DataXcassetsController(model: model, named: .gifs, resources: xcassets.gifs)
        try gifsController.run()
        
        let dataController = DataXcassetsController(model: model, named: .data, resources: model.xcassets.datas)
        try dataController.run()
    }
    
}
