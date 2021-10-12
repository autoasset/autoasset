import XCTest
import class Foundation.Bundle

final class AutoassetTests: XCTestCase {
    
    func testExample() throws {
        print(try runApp(arguments: ["--version"]))
        print(try runApp(arguments: ["--help"]))
    }
    
    func testApp1() throws {
        print(try runApp(arguments: []))
    }
    
    
    
    func testConfigHelp() throws {
        print(try runApp(arguments: ["config", "--help"]))
    }
    
    func testTidy() throws {
        print(try runApp(arguments: "tidy create -t '${recommend.package.name}' -o ./test.txt -d"
                            .split(separator: " ")
                            .map(\.description)))
        
        print(try runApp(arguments: "tidy copy -i ./test.txt -o /Users/linhey/Desktop -d"
                            .split(separator: " ")
                            .map(\.description)))
        
        print(try runApp(arguments: "tidy copy -i ./test.txt -o /Users/linhey/Desktop/debug -d"
                            .split(separator: " ")
                            .map(\.description)))
        
        print(try runApp(arguments: "tidy clear -i /Users/linhey/Desktop/test.txt -d"
                            .split(separator: " ")
                            .map(\.description)))
    }
    
    func testVariablesHelp() throws {
        print(try runApp(arguments: ["variables", "--help"]))
    }
    
    func testVariablesList() throws {
        print(try runApp(arguments: ["variables", "list"]))
    }
    
    func testVariables() throws {
        print(try runApp(arguments: ["variables", "-t", "${autoasset.date.now}"]))
        print(try runApp(arguments: ["variables", "--text", "${autoasset.date.now}"]))
    }
    
    func runApp(arguments: [String]) throws -> String {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return ""
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)
        let fooBinary = productsDirectory.appendingPathComponent("Autoasset")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
