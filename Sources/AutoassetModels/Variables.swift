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
import Stem

public enum PlaceHolder {
    
    case dateNow
    case dateFormat
    
    case gitRemoteURL
    case gitCurrentBranch
    case gitCurrentBranchNumber
    case gitCurrentCommitHash
    case gitCurrentCommitAuthor
    case gitCurrentCommitDate
    case gitCurrentCommitMessage
    
    case gitNextTagNumber
    case gitMaxTagNumber
    
    /// https://semver.org/
    /// MAJOR.MINOR.PATCH
    case gitTagMaxVersion
    case gitTagNextMajorVersion
    case gitTagNextMinorVersion
    case gitTagNextPatchVersion
    
    case recommendPackageName
    case recommendPackageNameCamelCase
    case recommendPackageNameSnakeCase
    
    case custom(key: String, value: String)
    
    public static var systems: [PlaceHolder] { [
        .dateNow,
        .dateFormat,
        .gitCurrentBranch,
        .gitCurrentBranchNumber,
        .gitMaxTagNumber,
        .gitNextTagNumber,
        .gitCurrentCommitHash,
        .gitCurrentCommitAuthor,
        .gitCurrentCommitDate,
        .gitCurrentCommitMessage,
        .gitRemoteURL,
        .recommendPackageName,
        .recommendPackageNameCamelCase,
        .recommendPackageNameSnakeCase,
        .gitTagMaxVersion,
        .gitTagNextMajorVersion,
        .gitTagNextMinorVersion,
        .gitTagNextPatchVersion,
    ]
    }
    
    var variable: String {
        switch self {
        case .recommendPackageName: return "recommend.package.name"
        case .recommendPackageNameCamelCase: return "recommend.package.name(.camelCase)"
        case .recommendPackageNameSnakeCase: return "recommend.package.name(.snakeCase)"
        case .dateNow:                 return "autoasset.date.now"
        case .dateFormat:              return "autoasset.date.format"
        case .gitRemoteURL:            return "autoasset.git.remote.url"
        case .gitCurrentBranch:        return "autoasset.git.branch.current"
        case .gitCurrentBranchNumber:  return "autoasset.git.branch.current.number"
        case .gitCurrentCommitHash:    return "autoasset.git.commit.current.hash"
        case .gitCurrentCommitAuthor:  return "autoasset.git.commit.current.author"
        case .gitCurrentCommitDate:    return "autoasset.git.commit.current.date"
        case .gitCurrentCommitMessage: return "autoasset.git.commit.current.message"
            
        case .gitNextTagNumber:        return "autoasset.git.tag.next.number"
        case .gitMaxTagNumber:         return "autoasset.git.tag.max.number"
            
        case .gitTagMaxVersion:        return "autoasset.git.tag.max.version"
        case .gitTagNextMajorVersion:  return "autoasset.git.tag.next.majorVersion"
        case .gitTagNextMinorVersion:  return "autoasset.git.tag.next.minorVersion"
        case .gitTagNextPatchVersion:  return "autoasset.git.tag.next.patchVersion"
            
        case .custom(key: let key, _): return key
        }
    }
    
    public var desc: String {
        switch self {
        case .recommendPackageName: return "获取当前 git URL 后缀名/根文件夹名"
        case .recommendPackageNameCamelCase: return "获取当前 git URL 后缀名/根文件夹名(驼峰命名)"
        case .recommendPackageNameSnakeCase: return "获取当前 git URL 后缀名/根文件夹名(下划线分割命名)"
        case .dateNow:                 return "获取当前时间"
        case .dateFormat:              return "设置时间格式, 默认为 yyyy-MM-dd HH:mm:ss"
        case .gitCurrentBranch:        return "获取当前 Git Branch 名称"
        case .gitCurrentBranchNumber:  return "获取当前 Git Branch 名称中的数字部分"
            
        case .gitNextTagNumber:        return "获取远端 Git Tags 中最大的数字 + 1, 未创建分支为 1"
        case .gitMaxTagNumber:         return "获取远端 Git Tags 中最大的数字, 未创建分支为 0"
        case .gitTagMaxVersion:        return "按照 Semantic Versioning 格式, 过滤出最大的版本号"
        case .gitTagNextMajorVersion:  return "按照 Semantic Versioning 格式, Major 位数字 +1"
        case .gitTagNextMinorVersion:  return "按照 Semantic Versioning 格式, Minor 位数字 +1"
        case .gitTagNextPatchVersion:  return "按照 Semantic Versioning 格式, Patch 位数字 +1"
            
        case .gitCurrentCommitAuthor:  return "获取当前 Git Commit 作者信息"
        case .gitCurrentCommitDate:    return "获取当前 Git Commit 提交日期"
        case .gitCurrentCommitMessage: return "获取当前 Git Commit 提交信息"
        case .gitCurrentCommitHash:    return "获取当前 Git Commit hash"
        case .gitRemoteURL: return "获取远程 URL"
        case .custom(key: let key, let value): return "key: \(key) value: \(value)"
        }
    }
    
    public var name: String { "${\(variable)}" }
    
}

public struct Variables {
    
    public struct RecommendPackage {
        public var name: String?
        public var camelName: String?
        public var snakeName: String?
        
        public func merge(_ model: RecommendPackage) -> RecommendPackage {
            return RecommendPackage(name: name ?? model.name,
                                    camelName: camelName ?? model.camelName,
                                    snakeName: snakeName ?? model.snakeName)
        }
    }
    
    public let dateFormat: String
    public let recommendPackage: RecommendPackage
    
    public let placeHolders: [PlaceHolder]
    public let placeHolderNames: Set<String>
    
    public func merge(_ model: Variables?) -> Variables {
        guard let model = model else {
            return self
        }
        return Variables(placeHolders: placeHolders + model.placeHolders,
                         dateFormat: dateFormat == "yyyy-MM-dd HH:mm:ss" ? model.dateFormat : dateFormat,
                         recommendPackage: recommendPackage.merge(model.recommendPackage))
    }
    
    public init(placeHolders newList: [PlaceHolder],
                dateFormat: String = "yyyy-MM-dd HH:mm:ss",
                recommendPackage: RecommendPackage) {
        var placeHolderNames = Set(PlaceHolder.systems.map(\.name))
        var placeHolders = PlaceHolder.systems
        
        for placeHolder in newList {
            guard placeHolderNames.insert(placeHolder.name).inserted else {
                continue
            }
            placeHolders.append(placeHolder)
        }
        
        self.placeHolderNames = placeHolderNames
        self.placeHolders = placeHolders
        self.dateFormat = dateFormat
        self.recommendPackage = recommendPackage
    }
    
    public init(placeHolders dictionary: [String: String]) {
        var dateFormat = "yyyy-MM-dd HH:mm:ss"
        var recommendPackage = RecommendPackage()
        
        var placeHolders = [PlaceHolder]()
        dictionary.forEach { (key, result) in
            switch key {
            case PlaceHolder.recommendPackageName.variable:
                let result = result.trimmingCharacters(in: .whitespacesAndNewlines)
                guard result.isEmpty == false else {
                    break
                }
                recommendPackage.name = result
            case PlaceHolder.recommendPackageNameCamelCase.variable:
                let result = result.trimmingCharacters(in: .whitespacesAndNewlines)
                guard result.isEmpty == false else {
                    break
                }
                recommendPackage.camelName = result
            case PlaceHolder.recommendPackageNameSnakeCase.variable:
                let result = result.trimmingCharacters(in: .whitespacesAndNewlines)
                guard result.isEmpty == false else {
                    break
                }
                recommendPackage.snakeName = result
            case PlaceHolder.dateFormat.variable:
                dateFormat = result.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                placeHolders.append(.custom(key: key, value: result.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }
        
        self.init(placeHolders: placeHolders,
                  dateFormat: dateFormat,
                  recommendPackage: recommendPackage)
    }
    
    
    init(from json: JSON) {
        self.init(placeHolders: json.dictionaryValue.compactMapValues(\.string))
    }
    
}
