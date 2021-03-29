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
    
    private let logger = Logger(label: "git")
    
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
    
    @discardableResult
    private func shell(_ command: String) throws -> String {
        logger.info(.init(stringLiteral: command))
        let output = run(bash: command)
        logger.info(.init(stringLiteral: output.stdout))
        return output.stdout
    }
}

public extension Git {
    
    enum TagOptions {
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
    
    func tag(options: [TagOptions] = []) throws -> String {
        let commands = ["git", "tag"]
            + options.map(\.command)
        let command = commands.joined(separator: " ")
        logger.info(.init(stringLiteral: command))
        let output = run(bash: command)
        logger.info(.init(stringLiteral: output.stdout))
        return output.stdout
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
    
    func status(options: [StatusOptions] = []) throws -> String {
        let commands = ["git", "status"]
            + options.map(\.command)
        let command = commands.joined(separator: " ")
        return try shell(command)
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
        try shell(command)
    }
    
}

// MARK: - ls-remote
public extension Git {
    
    /**
     Limit to only refs/heads and refs/tags, respectively. These options are not mutually exclusive; when given both, references stored in refs/heads and refs/tags are displayed. Note that git ls-remote -h used without anything else on the command line gives help, consistent with other git subcommands.
     */
    enum LsRemoteModeOptions: String {
        case heads = "--heads"
        case tags  = "--tags"
        var command: String { rawValue }
    }
    
    enum LsRemoteOptions {
        /// Do not show peeled tags or pseudorefs like HEAD in the output.
        case refs
        /// Do not print remote URL to stderr.
        case quiet
        /**
         Specify the full path of git-upload-pack on the remote host. This allows listing references from repositories accessed via SSH and where the SSH daemon does not use the PATH configured by the user.
         */
        case uploadPack(exec: String)
        /// Exit with status "2" when no matching refs are found in the remote repository. Usually the command exits with status "0" to indicate it successfully talked with the remote repository, whether it found any matching refs.
        case exitCode
        /**
         Expand the URL of the given remote repository taking into account any "url.<base>.insteadOf" config setting (See git-config[1]) and exit without talking to the remote.
         */
        case getURL
        /**
         In addition to the object pointed by it, show the underlying ref pointed by it when showing a symbolic ref. Currently, upload-pack only shows the symref HEAD, so it will be the only one shown by ls-remote.
         */
        case symref
        
        /**
         Sort based on the key given. Prefix - to sort in descending order of the value. Supports "version:refname" or "v:refname" (tag names are treated as versions). The "version:refname" sort order can also be affected by the "versionsort.suffix" configuration variable. See git-for-each-ref[1] for more sort options, but be aware keys like committerdate that require access to the objects themselves will not work for refs whose objects have not yet been fetched from the remote, and will give a missing object error.
         */
        case sort(key: String)
        
        var command: String {
            switch self {
            case .refs: return "--refs"
            case .quiet: return "--quiet"
            case .exitCode: return "--exitCode"
            case .uploadPack(let exec): return "--upload-pack \(exec)"
            case .getURL: return "--get-url"
            case .symref: return "--symref"
            case .sort(let key): return "--sort=\(key)"
            }
        }
    }
    
    /// Displays references available in a remote repository along with the associated commit IDs.
    func lsRemote(mode: [LsRemoteModeOptions],
                  options: [LsRemoteOptions] = [],
                  repository: String) throws -> String {
        let commands = ["git", "ls-remote"]
            + mode.map(\.command)
            + options.map(\.command)
            + [repository]
        let command = commands.joined(separator: " ")
        return try shell(command)
    }
    
}


// MARK: - rev-parse
public extension Git {
    
    enum RevParseModeOptions {
        /// Use git rev-parse in option parsing mode (see PARSEOPT section below).
        case parseopt([RevParseParseoptOptions] = [])
        /// Use git rev-parse in shell quoting mode (see SQ-QUOTE section below). In contrast to the --sq option below, this mode does only quoting. Nothing else is done to command input.
        case sqQuote
        
        var command: String {
            switch self {
            case .parseopt(let options): return (["--parseopt"] + options.map(\.rawValue)).joined(separator: " ")
            case .sqQuote: return "--sq-quote"
            }
        }
    }
    
    enum RevParseParseoptOptions: String {
        /// Only meaningful in --parseopt mode. Tells the option parser to echo out the first -- met instead of skipping it.
        case keepDashdash = "--keep-dashdash"
        /// Only meaningful in --parseopt mode. Lets the option parser stop at the first non-option argument. This can be used to parse sub-commands that take options themselves.
        case stopAtNonOption = "--stop-at-non-option"
        /// Only meaningful in --parseopt mode. Output the options in their long form if available, and with their arguments stuck.
        case stuckLong = "--stuck-long"
    }
    
    enum RevParseFilterOptions: String {
        /// Do not output flags and parameters not meant for git rev-list command.
        case revsOnly = "--revs-only"
        /// Do not output flags and parameters meant for git rev-list command.
        case noRevs = "--no-revs"
        /// Do not output non-flag parameters.
        case flags = "--flags"
        /// Do not output flag parameters.
        case noFlags = "--no-flags"
    }
    
    enum RevParseOutputOptions {
        /// If there is no parameter given by the user, use <arg> instead.
        case `default`(String)
        /**
         Behave as if git rev-parse was invoked from the <arg> subdirectory of the working tree. Any relative filenames are resolved as if they are prefixed by <arg> and will be printed in that form.
         
         This can be used to convert arguments to a command run in a subdirectory so that they can still be used after moving to the top-level of the repository. For example:
         
         ```
         prefix=$(git rev-parse --show-prefix)
         cd "$(git rev-parse --show-toplevel)"
         # rev-parse provides the -- needed for 'set'
         eval "set $(git rev-parse --sq --prefix "$prefix" -- "$@")"
         ```
         */
        case prefix(String)
        /**
         Verify that exactly one parameter is provided, and that it can be turned into a raw 20-byte SHA-1 that can be used to access the object database. If so, emit it to the standard output; otherwise, error out.
         
         If you want to make sure that the output actually names an object in your object database and/or can be used as a specific type of object you require, you can add the ^{type} peeling operator to the parameter. For example, git rev-parse "$VAR^{commit}" will make sure $VAR names an existing object that is a commit-ish (i.e. a commit, or an annotated tag that points at a commit). To make sure that $VAR names an existing object of any type, git rev-parse "$VAR^{object}" can be used.
         
         Note that if you are verifying a name from an untrusted source, it is wise to use --end-of-options so that the name argument is not mistaken for another option.
         
         quiet:
         
         Only meaningful in --verify mode. Do not output an error message if the first argument is not a valid object name; instead exit with non-zero status silently. SHA-1s for valid object names are printed to stdout on success.
         */
        case verify(quiet: Bool = false)
        
        /**
         Usually the output is made one line per flag and parameter. This option makes output a single line, properly quoted for consumption by shell. Useful when you expect your parameter to contain whitespaces and newlines (e.g. when using pickaxe -S with git diff-*). In contrast to the --sq-quote option, the command input is still interpreted as usual.
         */
        case sq
        /**
         Same as --verify but shortens the object name to a unique prefix with at least length characters. The minimum length is 4, the default is the effective value of the core.abbrev configuration variable (see git-config[1]).
         */
        case short(length: Int? = nil)
        /**
         When showing object names, prefix them with ^ and strip ^ prefix from the object names that already have one.
         */
        case not
        /**
         A non-ambiguous short name of the objects name. The option core.warnAmbiguousRefs is used to select the strict abbreviation mode.
         */
        case abbrevRef(names: [String])
        /**
         Usually the object names are output in SHA-1 form (with possible ^ prefix); this option makes them output in a form as close to the original input as possible.
         */
        case symbolic
        /**
         This is similar to --symbolic, but it omits input that are not refs (i.e. branch or tag names; or more explicitly disambiguating "heads/master" form, when you want to name the "master" branch when there is an unfortunately named tag "master"), and show them as full refnames (e.g. "refs/heads/master").
         */
        case symbolicFullName
        
        var command: String {
            switch self {
            case .default(let options): return ["--default", options].joined(separator: " ")
            case .prefix(let options):  return ["--prefix", options].joined(separator: " ")
            case .verify(let quiet): return  "--verify" + (quiet ? " --quiet" : "")
            case .sq: return "--sq"
            case .short(let length):
                var commands = ["--short"]
                if let length = length {
                    commands.append(length.description)
                }
                return commands.joined(separator: " ")
            case .not: return "--not"
            case .abbrevRef(names: let names): return (["--abbrev-ref"] + names).joined(separator: " ")
            case .symbolic: return "--symbolic"
            case .symbolicFullName: return "--symbolic-full-name"
            }
        }
    }
    
    func revParse(mode: RevParseModeOptions? = nil,
                  filers: [RevParseFilterOptions] = [],
                  output: [RevParseOutputOptions]) throws -> String {
        let commands = ["git", "rev-parse", mode?.command].compactMap({ $0 })
            + filers.map(\.rawValue)
            + output.map(\.command)
        let command = commands.joined(separator: " ")
        return try shell(command)
    }
    
}

