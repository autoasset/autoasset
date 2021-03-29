//
//  AutoAsset.swift
//  Test
//
//  Created by 林翰 on 2020/10/10.
//

import Foundation

public typealias Images = AutoAssetImage.self
public typealias Colors = AutoAssetColor.self
public typealias GIFs   = AutoAssetGIF.self
public typealias Datas  = AutoAssetData.self

public extension Images {

    var image: UIImage { value() }

}
