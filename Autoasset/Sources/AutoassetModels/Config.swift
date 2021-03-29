//
//  File.swift
//  
//
//  Created by 林翰 on 2021/3/19.
//

import Foundation
import StemCrossPlatform

public struct Config {
    
    public let modes: [Mode]
    public let environment: Environment
    public let warn: Warn?
    public let message: Message?
    public let cocoapods: Cocoapods?
    public let xcassets: Xcassets
    public let download: Download?
    public let tidy: Tidy
    public let variables: Variables
    
    public init(from json: JSON) {
        modes = json["modes"].arrayValue.compactMap(Mode.init(from:))
        environment = .init(from: json["environment"])
        warn = Warn(from: json["warn"])
        message = Message(from: json["message"])
        cocoapods = Cocoapods(from: json["cocoapods"])
        xcassets = Xcassets(from: json["xcassets"])
        download = Download(from: json["download"])
        tidy = Tidy(from: json["tidy"])
        variables = Variables(from: json["tidy"])
    }
    
}
