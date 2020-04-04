//
//  Podspec.swift
//  Autoasset
//
//  Created by 林翰 on 2020/3/31.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation
import SwiftShell
import Stem

class Podspec {

    let config: Config.Podspec

    enum Placeholder {
        static let version = "[version]"
        static let resource_bundles = "[resource_bundles]"
    }

    init(config: Config.Podspec) {
        self.config = config
    }

    func output() throws {
        guard let output = config.outputPath else {
            throw RunError(message: "Config: podspec/output_path 不能为空")
        }

        var template = ""
        
        if let path = config.templatePath?.path {
            template = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            template = createTemplate()
        }

        let version = try Git.lastTagVersion() + 1
        try template
            .replacingOccurrences(of: Placeholder.version, with: "\(version)")
            .data(using: .utf8)?
            .write(to: output)
    }


}

private extension Podspec {

    func createTemplate() -> String {
        return """
        Pod::Spec.new do |s|
          s.name             = 'Resources'
          # 内部版本标识
          s.version          = '1'
          s.summary          = 'UI资源包'

          s.description      = <<-DESC
          TODO: Add long description of the pod here.
          DESC

          s.homepage         = 'https://github.com/linhey/Resources'
          s.license          = { :type => 'MIT', :file => 'LICENSE' }
          s.author           = { 'linhey' => 'is.linhey@outlook.com' }
          s.source           = { :git => 'https://github.com/linhey/Resources.git', :tag => s.version.to_s }

          s.ios.deployment_target = '10.0'

          s.swift_version  = "4.2"
          s.swift_versions = ['4.0', '4.2', '5.0', '5.1', '5.2']
          s.requires_arc   = true

          s.source_files = ['Sources/*.swift']
          s.resource_bundles = {
            'Resources' => ['Sources/Resources/*.xcassets']
          }
        end
        """
    }

}
