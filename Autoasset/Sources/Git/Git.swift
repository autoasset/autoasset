// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Logging
import SwiftShell

public struct Git {
    
    private let shellLogger = Logger(label: "shell")

    public init() {}
    
    struct Error: LocalizedError {
        
        public let message: String
        public let code: Int
        public var errorDescription: String?

        public init(message: String, code: Int = 0) {
            self.message = message
            self.errorDescription = message
            self.code = code
        }
    }
    
}

public extension Git {
    
    enum StatusOptions {
        /// Give the output in the short-format.
        case short
        /// Show the branch and tracking info even in short-format.
        case branch
        /// Show the number of entries currently stashed away.
        case showStash

        var command: String {
            switch self {
            case .short: return "--short"
            case .branch: return "--branch"
            case .showStash: return "--show-stash"
            }
        }
    }

    func status(options: [StatusOptions] = []) throws {
        let commands = ["git", "status"]
            + options.map(\.command)
        let command = commands.joined(separator: " ")
        try runAndPrint(bash: command)
    }
    
}

// MARK: - clone
public extension Git {
    
     enum CloneOptions {
        case singleBranch
        case depth(Int)
        case branch(String)
        
        var command: String {
            switch self {
            case .singleBranch: return "--single-branch"
            case .depth(let depth): return "--depth \(depth)"
            case .branch(let branch): return "--branch \(branch)"
            }
        }
    }
    
     func clone(url: String, options: [CloneOptions] = [], to dir: String? = nil) throws {
        let commands = ["git", "clone"]
            + options.map(\.command)
            + [url, dir].compactMap { $0 }
        let command = commands.joined(separator: " ")
        try runAndPrint(bash: command)
    }
    
}
