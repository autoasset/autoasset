//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation
import CSV

class XcassetsReport {
    
    struct Row: CSVRowProtocol {
        let variableName: VariableName
        let inputs: InputFilePaths
        let outputFolderName: OutputFolderName
        let outputFolderPath: OutputFolderPath
        let inputSize: InputFilesSize
        
       static let byteCountFormatter = ByteCountFormatter()

        var inputSizeDescription: InputFilesSizeDescription {
            return .init(item: Self.byteCountFormatter.string(fromByteCount: Int64(inputSize.item)))
        }
        
        var row: [CSVColumnProtocol] {
            [variableName,
             outputFolderName,
             inputSize,
             inputSizeDescription,
             outputFolderPath,
             inputs]
        }
    }
    
    /// 变量名
    struct VariableName: CSVColumnProtocol {
        static var name: String = "variable_name"
        var value: String { item }
        var item: String
    }
    
    /// 输入的文件,以 | 号分割
    struct InputFilePaths: CSVColumnProtocol {
        static var name: String = "input_file_paths"
        var value: String { item.joined(separator: " | ") }
        var item: [String]
    }
    
    /// 输出文件夹名
    struct OutputFolderName: CSVColumnProtocol {
        static var name: String = "output_folder_name"
        var value: String { item }
        var item: String
    }
    
    /// 输入的文件总大小
    struct InputFilesSize: CSVColumnProtocol {
        static var name: String = "input_files_size"
        var value: String { "\(item)" }
        var item: Int
    }
    
    /// 格式化大小
    struct InputFilesSizeDescription: CSVColumnProtocol {
        static var name: String = "input_files_size_description"
        var value: String { item }
        var item: String
    }
    
    /// 输出文件夹路径
    struct OutputFolderPath: CSVColumnProtocol {
        static var name: String = "output_folder_path"
        var value: String { item }
        var item: String
    }
    
}
