//
//  ProductItem.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductItem: Codable, CustomStringConvertible, Equatable {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum CodingKeys: String, CodingKey {

        // keys converted from server key to new local key

        // converted for readability
        case id                 = "productId"
        case name               = "productName"
        case imageUrl           = "productImage"

        // converted to wrap optionals
        case _shortDescription  = "shortDescription"
        case _longDescription   = "longDescription"

        // keys unchanged
        case price
        case reviewRating
        case reviewCount
        case inStock
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // see custom coding keys for matching variables / keys
    var id: String
    var name: String
    var price: String
    var imageUrl: String
    var reviewRating: Float
    var reviewCount: Int
    var inStock: Bool

    // optionals (note: private scope works with Codable protocol)
    private var _shortDescription: String?
    private var _longDescription: String?

    ///////////////////////////////////////////////////////////
    // computed properties to wrap optionals
    ///////////////////////////////////////////////////////////

    var shortDescription: String {

        return _shortDescription ?? ""
    }

    var longDescription: String {

        return _longDescription ?? ""
    }

    ///////////////////////////////////////////////////////////
    // equality helper
    ///////////////////////////////////////////////////////////

    func equalTo(_ selfTest: ProductItem) -> Bool {

        // object check, i.e. same physical object
        guard self !== selfTest else { return true }

        // property level equality check
        return  self.id                 == selfTest.id                  &&
                self.name               == selfTest.name                &&
                self.price              == selfTest.price               &&
                self.imageUrl           == selfTest.imageUrl            &&
                self.price              == selfTest.price               &&
                self.reviewRating       == selfTest.reviewRating        &&
                self.reviewCount        == selfTest.reviewCount         &&
                self.inStock            == selfTest.inStock             &&
                self._shortDescription  == selfTest._shortDescription   &&
                self._longDescription   == selfTest._longDescription
    }
}

///////////////////////////////////////////////////////////
// global level protocol conformance
///////////////////////////////////////////////////////////

func ==(lhs: ProductItem, rhs: ProductItem) -> Bool {

    // call into class so class so any potential heirarchy is maintained
    return lhs.equalTo(rhs)
}
