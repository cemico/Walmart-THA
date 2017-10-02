//
//  NSLock_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////
//
// global scope extension(s)
// note: psudo-clip from https://gist.github.com/kristopherjohnson/d12877ee9a901867f599
//
///////////////////////////////////////////////////////////

extension NSLock {

    // auto lock/unlock wrapper around closure
    public func synchronized(_ criticalSection: () -> ()) {

        self.lock()
        criticalSection()
        self.unlock()
    }

    // auto lock/unlock wrapper around closure
    public func synchronizedResult<T>(_ criticalSection: () -> T) -> T {

        self.lock()
        let result = criticalSection()
        self.unlock()

        return result
    }
}
