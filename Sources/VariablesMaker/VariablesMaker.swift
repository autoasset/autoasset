//
//  File.swift
//  
//
//  Created by 林翰 on 2021/4/1.
//

import Foundation
import AutoassetModels
import Stem
import Git
import ASError
import Logging

public struct VariablesMaker {
    
    private let logger = Logger(label: "VariablesMaker")
    public let variables: Variables
    
    public init(_ variables: Variables) {
        self.variables = variables
    }
    
    public func textMaker(_ text: String?) throws -> String? {
        guard let text = text else {
            return nil
        }
        return try textMaker(text)
    }
    
    public func textMaker(_ text: String) throws -> String {
        var outputText = text
        
        for key in variables.placeHolderNames {
            guard outputText.contains(key), let placeHolder = variables.placeHolders.first(where: { $0.name == key }) else {
                continue
            }
            
            let replace: String
            switch placeHolder {
            case .custom(_, let value):
                replace = value
            case .dateFormat:
                replace = variables.dateFormat
            case .dateNow:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = variables.dateFormat
                replace = dateFormatter.string(from: Date())
            case .gitCurrentBranch:
                replace = try Git().revParse(output: [.abbrevRef(names: ["HEAD"])])
            case .gitCurrentBranchNumber:
                replace = try Git().revParse(output: [.abbrevRef(names: ["HEAD"])]).filter(\.isNumber)
            case .gitMaxTagNumber:
                replace = "\(try getGitMaxTagMumber())"
            case .gitNextTagNumber:
                replace = "\(try getGitMaxTagMumber() + 1)"
            case .gitCurrentCommitMessage:
                replace = try Git().log(options: [.maxCount(1)]).first?.message ?? " "
            case .gitCurrentCommitHash:
                replace = try Git().log(options: [.maxCount(1)]).first?.hash ?? ""
            case .gitCurrentCommitAuthor:
                replace = try Git().log(options: [.maxCount(1)]).first?.author ?? ""
            case .gitCurrentCommitDate:
                replace = try Git().log(options: [.maxCount(1)]).first?.date ?? ""
            case .gitRemoteURL:
                replace = try Git().lsRemote(options: [.getURL])
            case .recommendPackageName:
                replace = try recommendPackageName()
            case .recommendPackageNameCamelCase:
                if let name = variables.recommendPackage.camelName {
                    replace = name
                } else {
                    replace = NameFormatter().splitWords(try recommendPackageName()).map(\.localizedCapitalized).joined()
                }
            case .recommendPackageNameSnakeCase:
                if let name = variables.recommendPackage.snakeName {
                    replace = name
                } else {
                    replace = NameFormatter().snakeCased(try recommendPackageName())
                }
            case .gitTagMaxVersion:
                replace = try getGitTagMaxVersion().description
            case .gitTagNextMajorVersion:
                let version = try getGitTagMaxVersion()
                replace = STVersion(version.major + 1, version.minor, version.patch).description
            case .gitTagNextMinorVersion:
                let version = try getGitTagMaxVersion()
                replace = STVersion(version.major, version.minor + 1, version.patch).description
            case .gitTagNextPatchVersion:
                let version = try getGitTagMaxVersion()
                replace = STVersion(version.major, version.minor, version.patch + 1).description
            }
            guard replace.isEmpty == false else {
                throw ASError(message: "\(placeHolder.name) 无法获取值")
            }
            
            logger.info("系统变量替换 \(key): \(replace)")
            outputText = outputText.replacingOccurrences(of: key, with: replace)
        }
        
        if text == outputText {
            return outputText
        }
        
        return try self.textMaker(outputText)
    }
    
    public func fileMaker(_ input: String) throws -> String {
        let inputPath = try self.textMaker(input)
        let inputPathFile = FilePath.File(url: .init(fileURLWithPath: inputPath))
        guard let text = String(data: try inputPathFile.data(), encoding: .utf8) else {
            throw ASError(message: #function)
        }
        return try textMaker(text)
    }
}

private extension VariablesMaker {

    private func recommendPackageName() throws -> String {
        if let name = variables.recommendPackage.name {
            return name
        }
        
        func rootFolderName() throws -> String {
            let folder = try FilePath.Folder(path: "./")
            return folder.url.lastPathComponent
        }
        
        do {
            if let name = try Git().lsRemote(options: [.getURL])
                .split(separator: "/")
                .last?
                .split(separator: ".")
                .first?
                .description {
                return name
            } else {
                return try rootFolderName()
            }
        } catch {
            return try rootFolderName()
        }
    }
    
}

private extension VariablesMaker {
    
    func getGitTagNames() throws -> [String] {
        return try Git().lsRemote(mode: [.tags], options: [.refs], repository: "origin")
            .split(separator: "\n")
            .compactMap { $0.components(separatedBy: "refs/tags/").last }
    }
    
    func getGitTagMaxVersion() throws -> STVersion {
        return try getGitTagNames()
            .compactMap(STVersion.init(_:))
            .sorted(by: >)
            .first ?? STVersion(getGitMaxTagMumber(), 0, 0)
    }
    
    func getGitMaxTagMumber() throws -> Int {
        return try getGitTagNames()
            .compactMap { Int($0) }
            .sorted(by: >)
            .first ?? 0
    }
    
}
