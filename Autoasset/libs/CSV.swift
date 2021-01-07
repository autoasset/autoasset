//
//  CSV.swift
//  Autoasset
//
//  Created by 林翰 on 2021/1/7.
//  Copyright © 2021 linhey.autoasset. All rights reserved.
//

import Foundation

protocol CSVColumnProtocol {
    associatedtype Value
    static var name: String { get }
    var value: Value { get set }
}
