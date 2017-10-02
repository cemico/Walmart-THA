//
//  NSObject_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension NSObject {

    var className: String {

        return type(of: self).className
    }

    static var className: String {
        
        return String(describing: self)
    }
}

