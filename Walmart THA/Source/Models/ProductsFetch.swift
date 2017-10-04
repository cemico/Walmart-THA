//
//  ProductsFetch.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductsFetch: NSObject, NSCoding, Codable {

    // archiving, in swift 4, enum is slightly cleaner than struct containing static string constants
    enum ArchiveKeys: String {

        case id
        case products
        case totalProducts
        case pageNumber
        case pageSize
        case status
        case kind
        case etag

        // synthesized
        case version

        static var all: [ArchiveKeys] = [

            .id, .products, .totalProducts, .pageNumber, .pageSize, .status, .kind, .etag, .version
        ]

        func value(for productsFetch: ProductsFetch) -> Any {

            // getter
            switch self {

                case .id:                   return productsFetch.id
                case .products:             return productsFetch.products
                case .totalProducts:        return productsFetch.totalProducts
                case .pageNumber:           return productsFetch.pageNumber
                case .pageSize:             return productsFetch.pageSize
                case .status:               return productsFetch.status
                case .kind:                 return productsFetch.kind
                case .etag:                 return productsFetch.etag
                case .version:              return productsFetch.version
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

    // simple direct model class, no optionals or variable / key remapping
    var id: String
    var products: [ProductItem]
    var totalProducts: Int
    var pageNumber: Int
    var pageSize: Int
    var status: Int
    var kind: String
    var etag: String

    // synthesized
    private var _version: String?

    ///////////////////////////////////////////////////////////
    // computed properties to wrap optionals
    ///////////////////////////////////////////////////////////

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
        totalProducts   = aDecoder.decodeInteger(forKey: ArchiveKeys.totalProducts.rawValue)
        pageNumber      = aDecoder.decodeInteger(forKey: ArchiveKeys.pageNumber.rawValue)
        pageSize        = aDecoder.decodeInteger(forKey: ArchiveKeys.pageSize.rawValue)
        status          = aDecoder.decodeInteger(forKey: ArchiveKeys.status.rawValue)

        // strings
        id              = aDecoder.decodeObject(forKey: ArchiveKeys.id.rawValue) as? String ?? ""
        kind            = aDecoder.decodeObject(forKey: ArchiveKeys.kind.rawValue) as? String ?? ""
        etag            = aDecoder.decodeObject(forKey: ArchiveKeys.etag.rawValue) as? String ?? ""
        _version        = aDecoder.decodeObject(forKey: ArchiveKeys.version.rawValue) as? String ?? ""

        // arrays
        products        = aDecoder.decodeObject(forKey: ArchiveKeys.products.rawValue) as? [ProductItem] ?? []

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
            case .totalProducts, .pageNumber, .pageSize, .status:
                let value = Int.from(any: key.value(for: self))
                aCoder.encode(value, forKey: key.rawValue)

            // string types
            case .id, .kind, .etag, .version:
                let value = String.from(any: key.value(for: self))
                aCoder.encode(value, forKey: key.rawValue)

            // array types
            case .products:
                let value = Array<ProductItem>.from(any: key.value(for: self))
                aCoder.encode(value, forKey: key.rawValue)
            }
        }
    }

    ///////////////////////////////////////////////////////////
    // helpers
    ///////////////////////////////////////////////////////////

    class func create(contentsOfFile filePath: String) -> ProductsFetch? {

        // validate path
        guard FileManager.default.fileExists(atPath: filePath) else { return nil }
//        guard let url = URL(string: filePath) else { return nil }

        // read data
        if let productsFetched = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? ProductsFetch {

            // success
            return productsFetched
        }

        // no item
        return nil
    }

    func save(toFile filePath: String) -> Bool {

        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        do {

            let url = URL(fileURLWithPath: filePath)
            try data.write(to: url, options: .atomic)
            return true
        }
        catch {

            return false
        }
    }

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
