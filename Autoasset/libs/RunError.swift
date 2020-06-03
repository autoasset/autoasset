//
//  RunError.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

struct RunError: Error {
    let message: String
}


struct RunPrint {

    @discardableResult
    init(_ message: Any) {
        print(message)
    }

    @discardableResult
    init(debug message: Any, function: StaticString = #function, line: UInt = #line, file: StaticString = #file) {
        print("\(file) - \(line) - \(function): ", message)
    }
}

