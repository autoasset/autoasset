import Foundation
import ArgumentParser
import StemCrossPlatform
import Yams
import AutoassetModels
import AutoassetXcassets
import AutoassetDownload
import AutoassetCocoapods
import AutoassetTidy
import Git

public struct AutoAsset: ParsableCommand {

    public struct Environment {
        public let rootURL: URL
        public let config: Config
    }
    
    public static let configuration = CommandConfiguration(version: "26")
    public private(set) static var environment = Environment(rootURL: URL(string: "./")!, config: .init(from: JSON()))
    public var environment: Environment { Self.environment }

    @Argument(help: "配置文件路径")
    var config: String
    @Flag() var verbose = false
    
    public init() {}

    public func run() throws {
        let path = try FilePath(path: config, type: .file)
        let data = try path.data()
        guard let text = String(data: data, encoding: .utf8), let yml = try Yams.load(yaml: text) else {
            return
        }
        let model = Config(from: JSON(yml))
        AutoAsset.environment = .init(rootURL: path.url.deletingLastPathComponent(), config: model)
        begin()
    }
}

extension AutoAsset {
    
    func begin() {
        do {
            try placeholder(variables: environment.config.variables)
            //try environment.config.modes.forEach(run(with:))
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func placeholder(variables: Variables) throws -> PlaceHolder {
        let version: String
        
        try Git().status(options: [.])
        switch variables.version {
        case .fromGitBranch:
            version = "text"

        case .nextGitTag:
            version = "text"
        case .text(let text):
            version = text
        }
        return PlaceHolder(version: version)
    }
    
    func run(with mode: Mode) throws {
        switch mode {
        case .download:
            if let model = environment.config.download {
                try DownloadController(model: model).run()
            }
        case .cocoapods:
            if let model = environment.config.cocoapods {
                try CocoapodsController(model: model).run()
            }
        case .tidy(name: let name):
            try TidyController(model: environment.config.tidy).run(name: name)
        case .xcassets:
            try XcassetsController(model: environment.config).run()
        }
    }
    
}
