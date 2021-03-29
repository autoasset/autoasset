//
//  main.swift
//  RunApp
//
//  Created by 林翰 on 2021/3/26.
//

import Foundation
import AutoassetApp
import StemCrossPlatform

print(try FilePath(path: "./").url.description)

//AutoAsset.main(["--version"])
//AutoAsset.main(["--help"])
AutoAsset.main(["autoasset.yml"])
