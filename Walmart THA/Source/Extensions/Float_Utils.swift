//
//  Float_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Float {

    static func from(any: Any, default value: Float = 0) -> Float {

        return any as? Float ?? value
    }
}

