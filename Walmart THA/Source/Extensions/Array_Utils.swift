//
//  Array_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Array {

    static func from(any: Any, default value: Array = []) -> Array {

        return any as? Array ?? value
    }
}

