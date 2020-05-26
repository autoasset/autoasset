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
    init(_ message: Any, function: String = #function, line: Int = #line, file: String = #file) {
        print("\(file) - \(line) - \(function): ", message)
    }
}

