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
        
       XCTAssertEqual(formatter.camelCased("12") , "12")
       XCTAssertEqual(formatter.camelCased("1 2"), "12")
       XCTAssertEqual(formatter.camelCased("1_2"), "12")
       XCTAssertEqual(formatter.camelCased("1-2"), "12")
        
       XCTAssertEqual(formatter.camelCased("add white"), "addWhite")
       XCTAssertEqual(formatter.camelCased("add_white"), "addWhite")
       XCTAssertEqual(formatter.camelCased("add-white"), "addWhite")
        
       XCTAssertEqual(formatter.camelCased("add  white"), "addWhite")
       XCTAssertEqual(formatter.camelCased("add__white"), "addWhite")
       XCTAssertEqual(formatter.camelCased("add--white"), "addWhite")

       XCTAssertEqual(formatter.camelCased("3d_touch_code"), "3dTouchCode")
    }
    
    func testFileName() throws {
        let formatter = NameFormatter(split: ["_dark@", "_dark.", "@3x.", "@2x.", "@1x.", "."])
        
       XCTAssertEqual(formatter.fileName("a") , "a")
       XCTAssertEqual(formatter.fileName("a."), "a")
       XCTAssertEqual(formatter.fileName("a@1x."), "a")
       XCTAssertEqual(formatter.fileName("a@2x."), "a")
       XCTAssertEqual(formatter.fileName("a@3x."), "a")
       XCTAssertEqual(formatter.fileName("a_dark@3x."), "a")
       XCTAssertEqual(formatter.fileName("_dark") , "_dark")
       XCTAssertEqual(formatter.fileName("_dark."), "")
    }
    
    func testVariableName() throws {
        let formatter = NameFormatter(split: [" ", "-", "_"])
        XCTAssertEqual(formatter.variableName("add white", prefix: ""), "addWhite")
        XCTAssertEqual(formatter.variableName("add_white", prefix: ""), "addWhite")
        XCTAssertEqual(formatter.variableName("add-white", prefix: ""), "addWhite")

        XCTAssertEqual(formatter.variableName("add white", prefix: "_"), "_addWhite")
        XCTAssertEqual(formatter.variableName("add_white", prefix: "_"), "_addWhite")
        XCTAssertEqual(formatter.variableName("add-white", prefix: "_"), "_addWhite")
        
        XCTAssertEqual(formatter.variableName("3d add white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variableName("3d add_white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variableName("3d add-white", prefix: "_"), "_3dAddWhite")
        
        XCTAssertEqual(formatter.variableName("_3d add white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variableName("_3d add_white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variableName("_3d add-white", prefix: "_"), "_3dAddWhite")
        
        XCTAssertEqual(formatter.variableName("class", prefix: ""), "`class`")
        XCTAssertEqual(formatter.variableName("__COLUMN__", prefix: ""), "cOLUMN")
    }
    
    func testScanNumber() throws {
        let formatter = NameFormatter(split: [])
        XCTAssertEqual(formatter.scanNumbers("origin/UI/8.35.0"), "8350")
        XCTAssertEqual(formatter.scanNumbers("origin/master"), "")
        XCTAssertEqual(formatter.scanNumbers("origin/HEAD"), "")
    }

}
