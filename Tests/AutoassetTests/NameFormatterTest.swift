//
//  NameFormatterTest.swift
//  UnitTest
//
//  Created by 林翰 on 2020/12/7.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import XCTest
import VariablesMaker

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
        
       XCTAssertEqual(formatter.file("a") , "a")
       XCTAssertEqual(formatter.file("a."), "a")
       XCTAssertEqual(formatter.file("a@1x."), "a")
       XCTAssertEqual(formatter.file("a@2x."), "a")
       XCTAssertEqual(formatter.file("a@3x."), "a")
       XCTAssertEqual(formatter.file("a_dark@3x."), "a")
       XCTAssertEqual(formatter.file("_dark") , "_dark")
       XCTAssertEqual(formatter.file("_dark."), "")
    }
    
    func testVariableName() throws {
        let formatter = NameFormatter(split: [" ", "-", "_"])
        XCTAssertEqual(formatter.variable("add white", prefix: ""), "addWhite")
        XCTAssertEqual(formatter.variable("add_white", prefix: ""), "addWhite")
        XCTAssertEqual(formatter.variable("add-white", prefix: ""), "addWhite")

        XCTAssertEqual(formatter.variable("add white", prefix: "_"), "_addWhite")
        XCTAssertEqual(formatter.variable("add_white", prefix: "_"), "_addWhite")
        XCTAssertEqual(formatter.variable("add-white", prefix: "_"), "_addWhite")
        
        XCTAssertEqual(formatter.variable("3d add white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variable("3d add_white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variable("3d add-white", prefix: "_"), "_3dAddWhite")
        
        XCTAssertEqual(formatter.variable("_3d add white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variable("_3d add_white", prefix: "_"), "_3dAddWhite")
        XCTAssertEqual(formatter.variable("_3d add-white", prefix: "_"), "_3dAddWhite")
        
        XCTAssertEqual(formatter.variable("class", prefix: ""), "`class`")
        XCTAssertEqual(formatter.variable("__COLUMN__", prefix: ""), "cOLUMN")
    }
    
    func testScanNumber() throws {
        let formatter = NameFormatter(split: [])
        XCTAssertEqual(formatter.scanNumbers("origin/UI/8.35.0"), "8350")
        XCTAssertEqual(formatter.scanNumbers("origin/master"), "")
        XCTAssertEqual(formatter.scanNumbers("origin/HEAD"), "")
    }
    
    func testChinese() throws {
        let formatter = NameFormatter(split: [])
        formatter.enableTranslateVariableNameChineseToPinyin = true
        XCTAssertEqual(formatter.isChinese(.init("1")), false)
        XCTAssertEqual(formatter.isChinese(.init("a")), false)
        XCTAssertEqual(formatter.isChinese(.init(";")), false)
        XCTAssertEqual(formatter.isChinese(.init(" ")), false)
        XCTAssertEqual(formatter.isChinese(.init("一")), true)
        XCTAssertEqual(formatter.isChinese(.init("萨")), true)
        XCTAssertEqual(formatter.transformToPinYin("一二三四五六七"), "yi er san si wu liu qi")
        XCTAssertEqual(formatter.variable("6六six"), "_6LiuSix")
        XCTAssertEqual(formatter.variable("六6six"), "liu6Six")
        XCTAssertEqual(formatter.variable("六six6"), "liuSix6")
        XCTAssertEqual(formatter.variable("六six六6"), "liuSixLiu6")
    }

}
