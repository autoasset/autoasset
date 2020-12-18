//
//  NameFormatterTest.swift
//  UnitTest
//
//  Created by 林翰 on 2020/12/7.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import XCTest

class NameFormatterTest: XCTestCase {

    func testCamelCased() throws {
        let formatter = NameFormatter(split: [" ", "-", "_"])
        
        assert(formatter.camelCased("12")  == "12")
        assert(formatter.camelCased("1 2") == "12")
        assert(formatter.camelCased("1_2") == "12")
        assert(formatter.camelCased("1-2") == "12")
        
        assert(formatter.camelCased("add white") == "addWhite")
        assert(formatter.camelCased("add_white") == "addWhite")
        assert(formatter.camelCased("add-white") == "addWhite")
        
        assert(formatter.camelCased("add  white") == "addWhite")
        assert(formatter.camelCased("add__white") == "addWhite")
        assert(formatter.camelCased("add--white") == "addWhite")

        assert(formatter.camelCased("3d_touch_code") == "3dTouchCode")
    }
    
    func testFileName() throws {
        let formatter = NameFormatter(split: ["_dark@", "_dark.", "@3x.", "@2x.", "@1x.", "."])
        
        assert(formatter.fileName("a")  == "a")
        assert(formatter.fileName("a.") == "a")
        assert(formatter.fileName("a@1x.") == "a")
        assert(formatter.fileName("a@2x.") == "a")
        assert(formatter.fileName("a@3x.") == "a")
        assert(formatter.fileName("a_dark@3x.") == "a")
        assert(formatter.fileName("_dark")  == "_dark")
        assert(formatter.fileName("_dark.") == "")
    }
    
    func testVariableName() throws {
        let formatter = NameFormatter(split: [" ", "-", "_"])
        assert(formatter.variableName("add white", prefix: "") == "addWhite")
        assert(formatter.variableName("add_white", prefix: "") == "addWhite")
        assert(formatter.variableName("add-white", prefix: "") == "addWhite")

        assert(formatter.variableName("add white", prefix: "_") == "_addWhite")
        assert(formatter.variableName("add_white", prefix: "_") == "_addWhite")
        assert(formatter.variableName("add-white", prefix: "_") == "_addWhite")
        
        assert(formatter.variableName("3d add white", prefix: "_") == "_3dAddWhite")
        assert(formatter.variableName("3d add_white", prefix: "_") == "_3dAddWhite")
        assert(formatter.variableName("3d add-white", prefix: "_") == "_3dAddWhite")
        
        assert(formatter.variableName("_3d add white", prefix: "_") == "_3dAddWhite")
        assert(formatter.variableName("_3d add_white", prefix: "_") == "_3dAddWhite")
        assert(formatter.variableName("_3d add-white", prefix: "_") == "_3dAddWhite")
        
        assert(formatter.variableName("class", prefix: "") == "`class`")
        assert(formatter.variableName("__COLUMN__", prefix: "") == "cOLUMN")
    }
    
    func testScanNumber() throws {
        let formatter = NameFormatter(split: [])
        XCTAssertEqual(formatter.scanNumbers("origin/UI/8.35.0"), "8350")
    }

}
