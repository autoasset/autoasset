//
//  File.swift
//  
//
//  Created by linhey on 2021/7/9.
//

import Foundation
import AutoassetModels

struct FlutterParse {
    
    let model: IconFont.Model
    let template: IconFont.FlutterTemplate
    
    var code: String {
        let functions = model.glyphs
            .sorted(by: { $0.name < $1.name })
            .map { item in
                return "static const IconData  \(item.name) = const IconData(0x\(item.unicode), fontFamily: '\(template.fontFamily)',fontPackage: '\(template.fontPackage)');"
        }.joined(separator: "\n")
        let main = """
        import 'package:flutter/widgets.dart';
        
        class \(template.className) {
        
        \(functions)
        
        }
        """
        return main
    }
    
}
