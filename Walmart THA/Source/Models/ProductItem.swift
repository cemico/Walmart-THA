//
//  ProductItem.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

// NSOject required for NSCoding, and already has CustomStringConvertible, Equatable
class ProductItem: NSObject, NSCoding, Codable /*, CustomStringConvertible, Equatable */ {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    // json auto-serialization into object creation
    private enum CodingKeys: String, CodingKey {

        // keys converted from server key to new local key

        // converted for readability
        case id                 = "productId"
        case name               = "productName"
        case imageUrl           = "productImage"

        // converted to wrap optionals
        case _version           = "version"
        case _shortDescription  = "shortDescription"
        case _longDescription   = "longDescription"

        // keys unchanged
        case price
        case reviewRating
        case reviewCount
        case inStock
    }

    // archiving, in swift 4, enum is slightly cleaner than struct containing static string constants
    enum ArchiveKeys: String {

        // swift 4 nice, will auto-rawValue a String to match enum case
        // note: enums do not allow you to assign value from struct, only literals
        //       be sure to keep these enum names in sync with the constants K.AlarmItemKeys.*
        case id
        case name
        case price
        case imageUrl
        case reviewRating
        case reviewCount
        case inStock
        case shortDescription
        case longDescription

        // synthesized
        case version

        static var all: [ArchiveKeys] = [

            .id, .name, .price, .imageUrl, .reviewRating, .reviewCount, .inStock, .shortDescription, .longDescription, .version
        ]

        func value(for productItem: ProductItem) -> Any {

            // getter
            switch self {

                case .id:                   return productItem.id
                case .name:                 return productItem.name
                case .price:                return productItem.price
                case .imageUrl:             return productItem.imageUrl
                case .reviewRating:         return productItem.reviewRating
                case .reviewCount:          return productItem.reviewCount
                case .inStock:              return productItem.inStock
                case .shortDescription:     return productItem.shortDescription
                case .longDescription:      return productItem.longDescription
                case .version:              return productItem.version
            }
        }
    }

    private enum Versions: String {

        struct Constants {

            // number of fractional digits supported
            static let versionPrecision = 2
        }

        // version the model to allow upgrade path if model changes in future
        case v1_00 = "1.00"

        // latest version
        static var currentVersion = Versions.v1_00
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

    // synthesized
    private var _version: String?

    ///////////////////////////////////////////////////////////
    // computed properties to wrap optionals
    ///////////////////////////////////////////////////////////

    var shortDescription: String {

        return _shortDescription ?? ""
    }

    var longDescription: String {

        return _longDescription ?? ""
    }

    var version: String {

        return _version ?? ""
    }

    //
    // NSCoding protocol
    //

    required init?(coder aDecoder: NSCoder) {

        //
        // used to restore / unarchive a previous alarm value which was archived / encoded
        //

        // ints
        reviewCount         = aDecoder.decodeInteger(forKey: ArchiveKeys.reviewCount.rawValue)

        // strings
        id                  = aDecoder.decodeObject(forKey: ArchiveKeys.id.rawValue) as? String ?? ""
        name                = aDecoder.decodeObject(forKey: ArchiveKeys.name.rawValue) as? String ?? ""
        price               = aDecoder.decodeObject(forKey: ArchiveKeys.price.rawValue) as? String ?? ""
        imageUrl            = aDecoder.decodeObject(forKey: ArchiveKeys.imageUrl.rawValue) as? String ?? ""
        _shortDescription   = aDecoder.decodeObject(forKey: ArchiveKeys.shortDescription.rawValue) as? String ?? ""
        _longDescription    = aDecoder.decodeObject(forKey: ArchiveKeys.longDescription.rawValue) as? String ?? ""
        _version            = aDecoder.decodeObject(forKey: ArchiveKeys.version.rawValue) as? String ?? ""

        // bools
        inStock             = aDecoder.decodeBool(forKey: ArchiveKeys.inStock.rawValue)

        // floats
        reviewRating        = aDecoder.decodeFloat(forKey: ArchiveKeys.reviewRating.rawValue)

        // after variables initialized
        super.init()

        // check for upgrade
        updateToCurrent()
    }

    func encode(with aCoder: NSCoder) {

        //
        // used to encode / archive this object
        //

        // save
        for key in ArchiveKeys.all {

            // coerce from Any into native types
            switch key {

                // int types
                case .reviewCount:
                    let value = Int.from(any: key.value(for: self))
                    aCoder.encode(value, forKey: key.rawValue)

                // string types
                case .id, .name, .price, .imageUrl, .shortDescription, .longDescription, .version:
                    let value = String.from(any: key.value(for: self))
                    aCoder.encode(value, forKey: key.rawValue)

                // bool types
                case .inStock:
                    let value = Bool.from(any: key.value(for: self))
                    aCoder.encode(value, forKey: key.rawValue)

                // float types
                case .reviewRating:
                    let value = Float.from(any: key.value(for: self))
                    aCoder.encode(value, forKey: key.rawValue)
            }
        }
    }

    ///////////////////////////////////////////////////////////
    // helpers
    ///////////////////////////////////////////////////////////

    private func updateToCurrent() {

        // example versioning logic
        guard version != Versions.currentVersion.rawValue else {

            // same version - no upgrade
            return
        }

        // upgrade older version to current, could be actions at each version change
        if version == Versions.v1_00.rawValue {

            // upgrade from 1.00 to current

            // udpate version
            _version = Versions.v1_00.rawValue
        }
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
