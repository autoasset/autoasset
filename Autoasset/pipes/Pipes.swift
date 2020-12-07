//
//  File.swift
//  Autoasset
//
//  Created by 林翰 on 2020/9/19.
//  Copyright © 2020 linhey.autoasset. All rights reserved.
//

import Foundation

protocol Pipes {
    
    associatedtype Input
    associatedtype Output
    
    init(_ input: Input)
    
    func flow() -> Output?
}

extension Pipes where Input == Void {

    init() {
        self.init(())
    }

}

extension Pipes {

    func flow<NewOutput, T: Pipes>(_ pipes: T.Type) -> NewOutput? where T.Input == Output, T.Output == NewOutput {
        guard let input = flow() else {
            return nil
        }
        return pipes.init(input).flow()
    }

}
