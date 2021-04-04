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
import StemCrossPlatform

public struct Cocoapods {
    
    public enum Trunk {
        
        case github
        case git(url: String)
        
        init?(from json: JSON) {
            if json["isGithub"].boolValue {
                self = .github
            } else if let repo = json["repo"].string,
                      repo.isEmpty == false {
                self = .git(url: repo)
            } else {
                return nil
            }
        }
    }
    
    public enum GitPush {
        case branch
        case tag
        case none
    }
    
    public struct Git {
        public let commitMessage: String
        public let pushMode: GitPush
        
        public init(commitMessage: String,
                    pushMode: GitPush) {
            self.commitMessage = commitMessage
            self.pushMode = pushMode
        }
        
        init?(from json: JSON) {
            commitMessage = json["commitMessage"].stringValue
            if json["pushToBranch"].boolValue {
                pushMode = .branch
            } else if json["pushToTag"].boolValue {
                pushMode = .tag
            } else {
                pushMode = .none
            }
            if commitMessage.isEmpty {
                return nil
            }
        }
    }
    
    public let trunk: Trunk?
    public let git: Git?
    public let podspec: String
    
    public init(trunk: Trunk?,
                git: Git?,
                podspec: String) {
        self.trunk = trunk
        self.git = git
        self.podspec = podspec
    }
    
    init?(from json: JSON) {
        
        trunk   = Trunk(from: json["trunk"])
        git     = Git(from: json["git"])
        podspec = json["podspec"].stringValue
        
        if podspec.isEmpty {
            return nil
        }
    }
    
}
