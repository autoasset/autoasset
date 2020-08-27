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
    RunPrint.create(titleDesc: "command", title: command, level: .info)

    let out = run(bash: command)

    if out.stdout.isEmpty == false {
        RunPrint("stdout: \(out.stdout)")
    }

    if out.succeeded {
        RunPrint.iconSuccess()
    } else {
        RunPrint.iconFail()
        if useAssert {
            throw RunError(message: out.stderror.isEmpty ? out.stdout : out.stderror)
        } else {
            RunPrint(out.stderror)
        }
    }

    RunPrint.createEnd()
    return out
}
