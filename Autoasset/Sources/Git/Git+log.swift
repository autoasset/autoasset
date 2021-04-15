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
import StemCrossPlatform

// MARK: - add
public extension Git {
    
    enum LogOptions {
        
        case maxCount(_ number: Int)
        
        var command: String {
            switch self {
            case .maxCount(let count): return "--max-count=\(count)"
            }
        }
        
    }
    
    struct LogResult {
        public let hash: String
        public let author: String
        public let date: String
        public let message: String
    }
    
    func log(options: [LogOptions] = []) throws -> [LogResult] {
        let commands = ["git", "log"]
            + options.map(\.command)
        let command = commands.joined(separator: " ")
        let result = try shell(command, logger: logger)
        
        var list = [LogResult]()
        
        var hash: String?
        var author: String?
        var date: String?
        var message: String = ""
        
        for row in result.split(separator: "\n") {
            
            if row.hasPrefix("commit "), row.count == 47 {
                if let hashRow = hash, let authorRow = author, let dateRow = date {
                    list.append(.init(hash: hashRow,
                                      author: authorRow,
                                      date: dateRow,
                                      message: message.trimmingCharacters(in: .whitespacesAndNewlines)))
                    hash = nil
                    author = nil
                    date = nil
                    message = ""
                }
                hash = row.description.st.deleting(prefix: "commit ").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if row.hasPrefix("Author: ") {
                author = row.description.st.deleting(prefix: "Author: ").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if row.hasPrefix("Date: ") {
                date = row.description.st.deleting(prefix: "Date: ").trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                message += row
            }
            
        }
        
        if let hashRow = hash, let authorRow = author, let dateRow = date {
            list.append(.init(hash: hashRow,
                              author: authorRow,
                              date: dateRow,
                              message: message.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        
        return list
    }
    
}
