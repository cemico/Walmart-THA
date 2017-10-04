//
//  ProductsFetch.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductsFetch: Codable, Equatable {

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // simple direct model class, no optionals or variable / key remapping
    var id: String
    var products: [ProductItem]
    var totalProducts: Int
    var pageNumber: Int
    var pageSize: Int
    var status: Int
    var kind: String
    var etag: String

    ///////////////////////////////////////////////////////////
    // equality helper
    ///////////////////////////////////////////////////////////

    func equalTo(_ selfTest: ProductsFetch) -> Bool {

        // object check, i.e. same physical object
        guard self !== selfTest else { return true }

        // property level equality check
        return  self.id         == selfTest.id              &&
            self.products       == selfTest.products        &&
            self.totalProducts  == selfTest.totalProducts   &&
            self.pageNumber     == selfTest.pageNumber      &&
            self.pageSize       == selfTest.pageSize        &&
            self.status         == selfTest.status          &&
            self.kind           == selfTest.kind            &&
            self.etag           == selfTest.etag
    }
}

///////////////////////////////////////////////////////////
// global level protocol conformance
///////////////////////////////////////////////////////////

func ==(lhs: ProductsFetch, rhs: ProductsFetch) -> Bool {

    // call into class so class so any potential heirarchy is maintained
    return lhs.equalTo(rhs)
}
