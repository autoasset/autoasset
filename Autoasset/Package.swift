// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let AutoassetApp = "AutoassetApp"
let AutoassetTidy = "AutoassetTidy"
let AutoassetXcassets = "AutoassetXcassets"
let AutoassetIconFont = "AutoassetIconFont"
let AutoassetDownload = "AutoassetDownload"
let AutoassetModels = "AutoassetModels"
let AutoassetCocoapods = "AutoassetCocoapods"
let Git = "Git"
let CSV = "CSV"
let Bash = "Bash"
let ASError = "ASError"
let VariablesMaker = "VariablesMaker"

let package = Package(
    name: "autoasset",
    platforms: [ .macOS(.v10_15) ],
    products: [
        .library(name: AutoassetApp, targets: [AutoassetApp]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/linhay/Stem.git", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0")
    ],
    targets: [
        .target(name: AutoassetModels, dependencies: [
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Yams", package: "Yams"),
        ]),
        
        .target(name: AutoassetTidy, dependencies: [
            .init(stringLiteral: ASError),
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral: AutoassetModels),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: AutoassetDownload, dependencies: [
            .init(stringLiteral: Git),
            .init(stringLiteral: ASError),
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral: AutoassetModels),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: AutoassetCocoapods, dependencies: [
            .init(stringLiteral: Git),
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral: AutoassetModels),
            .init(stringLiteral: ASError),
            .init(stringLiteral: Bash),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "SwiftShell", package: "SwiftShell"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: AutoassetXcassets, dependencies: [
            .init(stringLiteral:CSV),
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral:AutoassetModels),
            .init(stringLiteral: ASError),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: AutoassetIconFont, dependencies: [
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral:AutoassetModels),
            .init(stringLiteral: ASError),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: Git, dependencies: [
            .init(stringLiteral: ASError),
            .init(stringLiteral: Bash),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "SwiftShell", package: "SwiftShell"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: Bash, dependencies: [
            .init(stringLiteral: ASError),
            .product(name: "SwiftShell", package: "SwiftShell"),
            .product(name: "Logging", package: "swift-log")
        ]),
        
        .target(name: VariablesMaker, dependencies: [
            .init(stringLiteral: ASError),
            .init(stringLiteral: Git),
            .init(stringLiteral: AutoassetModels),
            .product(name: "StemCrossPlatform", package: "Stem"),
        ]),
        
        .target(name: ASError, dependencies: []),
        .target(name: CSV, dependencies: []),

        .target(name: AutoassetApp, dependencies: [
            .init(stringLiteral: ASError),
            .init(stringLiteral: Git),
            .init(stringLiteral: Bash),
            .init(stringLiteral: VariablesMaker),
            .init(stringLiteral: AutoassetDownload),
            .init(stringLiteral: AutoassetModels),
            .init(stringLiteral: AutoassetXcassets),
            .init(stringLiteral: AutoassetCocoapods),
            .init(stringLiteral: AutoassetTidy),
            .init(stringLiteral: AutoassetIconFont),
            .product(name: "StemCrossPlatform", package: "Stem"),
            .product(name: "Yams", package: "Yams"),
            .product(name: "SwiftShell", package: "SwiftShell"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Logging", package: "swift-log")
        ]),
    ]
)
