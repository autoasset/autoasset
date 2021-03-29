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
