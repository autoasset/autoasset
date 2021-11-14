//
//  File.swift
//  
//
//  Created by linhey on 2021/11/14.
//

import Foundation

enum Validate {
    
    enum Level: Int {
        case error
        case warning
    }
    
    /// [error] 重复文件错误
    case duplicate_resource_files(String)
    /// [warning] 有 content 文件存在却未被使用
    case content_file_not_used(String)
    
    
    var level: Level {
        switch self {
        case .duplicate_resource_files:
            return .error
        case .content_file_not_used:
            return .warning
        }
    }
    
}
