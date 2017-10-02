//
//  ProductsFetch.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductsFetch: Codable {

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
}
