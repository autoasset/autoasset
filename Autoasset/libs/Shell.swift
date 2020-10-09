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
func shell(_ command: String, useAssert: Bool = true, in rootURL: URL? = Env.rootURL) throws -> RunOutput {
    RunPrint.create(titleDesc: "command", title: command, level: .info)

    var newCommand = command

    if let path = rootURL?.path {
        newCommand = "cd \(path) && \(newCommand)"
    }

    let out = run(bash: newCommand)

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
