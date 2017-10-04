//
//  Int_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Int {

    static func from(any: Any, default value: Int = 0) -> Int {

        return any as? Int ?? value
    }
}

