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
func shell(_ command: String) throws -> RunOutput {
    let out = run(bash: command)
    if Autoasset.isDebug {
        print([String](repeating: "↓", count: 80).joined())
        print("command: \(command)")
        if out.stdout.isEmpty == false {
            print("stdout: \(out.stdout)")
        }
        if out.stderror.isEmpty == false {
            print("stderror: \(out.stderror)")
            throw RunError(message: out.stderror)
        }
        print([String](repeating: "↑", count: 80).joined())
        print("\n")
    }
    return out
}
