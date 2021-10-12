//
//  File.swift
//  
//
//  Created by linhey on 2021/8/8.
//

import Foundation
import AutoassetModels
import Stem
import Yams

class Global {
    
    static var env: Variables?
    
    static func config(from path: String) throws -> Config? {
        let path = try FilePath.File(path: path)
        let data = try path.data()
        guard let text = String(data: data, encoding: .utf8), let yml = try Yams.load(yaml: text) else {
            return nil
        }
        return Config(from: JSON(yml))
    }
    
}
