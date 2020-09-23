//
//  RunError.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

struct RunError: LocalizedError {
    let message: String
    var localizedDescription: String { message }
    var errorDescription: String? { message }
}
