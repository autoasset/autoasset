//
//  Shell.swift
//  Autoasset
//
//  Created by 林翰 on 2020/4/9.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell

func command(_ message: String) {
    RunPrint([String](repeating: "↓", count: 80).joined())
    RunPrint("command: \(message)")
    RunPrint([String](repeating: "↑", count: 80).joined())
}

@discardableResult
func shell(_ command: String, useAssert: Bool = true, function: StaticString = #function, line: UInt = #line, file: StaticString = #file) throws -> RunOutput {
    RunPrint([String](repeating: "↓", count: 80).joined())
    RunPrint("command: \(command)")
    RunPrint([String](repeating: "-", count: 80).joined())

    let out = run(bash: command)

    if out.stdout.isEmpty == false {
        RunPrint("stdout: \(out.stdout)")
    }

    if out.succeeded {
        RunPrint([String](repeating: "🎉", count: 40).joined())
    } else {
        RunPrint([String](repeating: "❌", count: 40).joined())
        RunPrint("stderror: \(out.stderror)")
        if useAssert {
            throw RunError(message: out.stderror)
        } else {
            RunPrint(out.stderror)
        }
    }

    RunPrint([String](repeating: "↑", count: 80).joined())
    RunPrint("\n")
    return out
}
