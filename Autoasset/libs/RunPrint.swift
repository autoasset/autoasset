//
//  RunPrint.swift
//  Autoasset
//
//  Created by 林翰 on 2020/9/23.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

struct RunPrint {

    struct Level: OptionSet {

        var rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let `default`: Level = .init(rawValue: 0)
        public static let info: Level      = .init(rawValue: 1)
        public static let debug: Level     = .init(rawValue: 2)
        public static let error: Level     = .init(rawValue: 3)
        public static let fault: Level     = .init(rawValue: 4)
    }

    @discardableResult
    init(_ message: Any, level: Level = .default) {
        print(message)
    }

    static func iconSuccess() {
        RunPrint([String](repeating: "🎉", count: 40).joined())
    }

    static func iconFail() {
        RunPrint([String](repeating: "❎", count: 40).joined())
    }

    static func create(titleDesc desc: String = "", title: String, level: Level = .default) {
        let text = desc.isEmpty ? title : "\(desc): \(title)"
        RunPrint([String](repeating: "↓", count: 80).joined(), level: level)
        RunPrint(text, level: level)
        RunPrint([String](repeating: "-", count: 80).joined(), level: level)
    }

    static func create(row text: String, level: Level = .default) {
        RunPrint(" - \(text)", level: level)
    }

    static func createEnd(level: Level = .default) {
        RunPrint([String](repeating: "↑", count: 80).joined())
        RunPrint("\n")
    }

    @discardableResult
    init(debug message: Any, function: StaticString = #function, line: UInt = #line, file: StaticString = #file) {
        RunPrint("\(file) - \(line) - \(function): \(message)", level: .debug)
    }
}

