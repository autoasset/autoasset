// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let Autoasset = "Autoasset"
let AutoassetiOSCode = "AutoassetiOSCode"
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

let StemDependency = Target.Dependency.product(name: "Stem", package: "Stem")
let LoggingDependency = Target.Dependency.product(name: "Logging", package: "swift-log")
let ShellDependency = Target.Dependency.product(name: "SwiftShell", package: "SwiftShell")

let package = Package(
    name: Autoasset,
    platforms: [ .macOS(.v10_15) ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/linhay/Stem.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "4.0.6")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/kareman/SwiftShell.git", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(name: AutoassetModels, dependencies: [
            StemDependency,
            .product(name: "Yams", package: "Yams"),
        ]),
        
            .target(name: AutoassetTidy, dependencies: [
                .init(stringLiteral: ASError),
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral: AutoassetModels),
                StemDependency,
                LoggingDependency,
            ]),
        
            .target(name: AutoassetDownload, dependencies: [
                .init(stringLiteral: Git),
                .init(stringLiteral: ASError),
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral: AutoassetModels),
                StemDependency,
                LoggingDependency,
            ]),
        
            .target(name: AutoassetCocoapods, dependencies: [
                .init(stringLiteral: Git),
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral: AutoassetModels),
                .init(stringLiteral: ASError),
                .init(stringLiteral: Bash),
                StemDependency,
                ShellDependency,
                LoggingDependency,
            ]),
        
            .target(name: AutoassetiOSCode, dependencies: [
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral: AutoassetModels),
                .init(stringLiteral: ASError),
                StemDependency,
                LoggingDependency,
            ]),
        
            .target(name: AutoassetXcassets, dependencies: [
                .init(stringLiteral: CSV),
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral: AutoassetModels),
                .init(stringLiteral: ASError),
                .init(stringLiteral: AutoassetiOSCode),
                StemDependency,
                LoggingDependency,
            ]),
        
            .target(name: AutoassetIconFont, dependencies: [
                .init(stringLiteral: VariablesMaker),
                .init(stringLiteral:AutoassetModels),
                .init(stringLiteral: ASError),
                .init(stringLiteral: AutoassetiOSCode),
                StemDependency,
                LoggingDependency,
            ]),
        
            .target(name: Git, dependencies: [
                .init(stringLiteral: ASError),
                .init(stringLiteral: Bash),
                StemDependency,
                ShellDependency,
                LoggingDependency,
            ]),
        
            .target(name: Bash, dependencies: [
                .init(stringLiteral: ASError),
                ShellDependency,
                LoggingDependency,
            ]),
        
            .target(name: VariablesMaker, dependencies: [
                .init(stringLiteral: ASError),
                .init(stringLiteral: Git),
                .init(stringLiteral: AutoassetModels),
                StemDependency,
            ]),
        
            .target(name: ASError, dependencies: []),
        .target(name: CSV, dependencies: []),
        .executableTarget(name: Autoasset, dependencies: [
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
            StemDependency,
            ShellDependency,
            LoggingDependency,
            .product(name: "Yams", package: "Yams"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "AutoassetTests",
                    dependencies: [
                        .init(stringLiteral: Autoasset),
                        .init(stringLiteral: AutoassetDownload),
                    ]),
    ]
)
