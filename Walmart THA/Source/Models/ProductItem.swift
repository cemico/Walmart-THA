//
//  ProductItem.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductItem: Codable, CustomStringConvertible {

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
}

