//
//  Bool_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Bool {

    static func from(any: Any, default value: Bool = false) -> Bool {

        return any as? Bool ?? value
    }
}

