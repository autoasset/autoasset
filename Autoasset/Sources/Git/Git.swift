//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

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
