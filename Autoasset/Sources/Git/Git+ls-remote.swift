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
import Bash

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
    func lsRemote(mode: [LsRemoteModeOptions] = [],
                  options: [LsRemoteOptions] = [],
                  repository: String? = nil) throws -> String {
        let commands = ["git", "ls-remote"]
            + mode.map(\.command)
            + options.map(\.command)
            + [repository]
        let command = commands.compactMap({ $0 }).joined(separator: " ")
        return try shell(command, logger: logger)
    }
    
}

