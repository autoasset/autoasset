//
//  Shell.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/9.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell

@discardableResult
func shell(_ command: String, useAssert: Bool = true, function: StaticString = #function, line: UInt = #line, file: StaticString = #file) throws -> RunOutput {
    let out = run(bash: command)
    switch Autoasset.mode.type {
    case .normal, .local, .test_message, .test_podspec, .test_warn, .pod_with_branch:
        print([String](repeating: "↓", count: 80).joined())
        print("command: \(command)")
        print([String](repeating: "-", count: 80).joined())
        if out.stdout.isEmpty == false {
            print("stdout: \(out.stdout)")
        }
        if out.stderror.isEmpty == false {
            RunPrint("stderror: \(out.stderror)", function: function, line: line, file: file)
            if useAssert {
                throw RunError(message: out.stderror)
            } else {
                RunPrint(out.stderror, function: function, line: line, file: file)
            }
        }
        print([String](repeating: "↑", count: 80).joined())
        print("\n")
    }
    return out
}
