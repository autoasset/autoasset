//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/28.
//

import Foundation

public protocol CSVColumnProtocol {
    static var name: String { get }
    var value: String { get }
}

public protocol CSVRowProtocol {
    var row: [CSVColumnProtocol] { get }
}

public class CSV {
    
    public var rows: [CSVRowProtocol]
    
    public init(rows: [CSVRowProtocol]) {
        self.rows = rows
    }
    
    public func file() -> Data? {
        guard let first = rows.first else {
            return nil
        }
        
        let list = [first.row.map { type(of: $0).name }] + rows.map { $0.row.map(\.value) }
        let file = list
            .map { $0.joined(separator: ",") }
            .joined(separator: "\n")
            .data(using: .utf8)
        
        return file
    }
    
}
