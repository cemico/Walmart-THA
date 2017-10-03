//
//  ProductDataController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class ProductDataController {

    ///////////////////////////////////////////////////////////
    // error enums
    ///////////////////////////////////////////////////////////

    enum ApiError: Error {

        case badOrEmptyData(reason: String)
        case badRequest(reason: String)
        case badHttpStatus(reason: String)
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let shared = ProductDataController()

    // limit access
    private var _products: [ProductItem] = []

    // server supplied total
    private var _lastProductsFetched: ProductsFetch? = nil

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private init() {

        print("\(String.className(ofSelf: self)).\(#function)")
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var products: [ProductItem] {

        // read-only / only getter
        return _products
    }

    var isMoreDataAvailableToFetch: Bool {

        var moreDataExists = true

        // no need to fetch once we're at the total
        if let lastProductsFetched = _lastProductsFetched {

            // also checked if total isn't accurate by checking if return is less than requested
            if products.count >= lastProductsFetched.totalProducts ||
                lastProductsFetched.pageSize != lastProductsFetched.products.count {

                // no new products
                moreDataExists = false
            }
        }

        return moreDataExists
    }

    ///////////////////////////////////////////////////////////
    // api
    ///////////////////////////////////////////////////////////

    func clear() {

        // thread-safe operation
        // note: another common way to control access is to use custom serial queue
        NSLock().synchronized { [unowned self] in

            // clear cached items
            self._products = []
            self._lastProductsFetched = nil
        }
    }

    func getPartialProductList(completionHandler: @escaping ((Error?, [ProductItem]) -> Void)) {

        // no need to fetch once we're at the total
        guard isMoreDataAvailableToFetch else {

            // no new products
            completionHandler(nil, [])
            return
        }

        // pickup where we last left off
        let pageNumber = 1 + products.count
        let parameters = [ Router.Constants.Api.Keys.getPartialProductList.start : pageNumber ]

        // make server request
        guard let request = try? Router.getPartialProductList(parameters).asURLRequest() else { completionHandler(nil, []); return }
        URLSession.dataRequest(request: request) { (data: Data?, error: Error?) in

            // validation - no error
            if let error = error {

                print(error.localizedDescription)
                completionHandler(error, [])
                return
            }

            // validation - data exists
            guard let data = data else {

                let error = ApiError.badOrEmptyData(reason: "No data returned")
                print(error.localizedDescription)
                completionHandler(error, [])
                return
            }

            // setup return values
            var returnError: Error? = nil
            var newProducts: [ProductItem] = []

            do {

                // use swift 4's new json codable protocol for our conforming model classes
                let decoder = JSONDecoder()
                let productsFetched = try decoder.decode(ProductsFetch.self, from: data)

                // additional layer to determine success, using http status code of server's response
                let success = (productsFetched.status == Router.Constants.HttpStatus.ok)
                if success {

                    // save last fetched, totalProducts field comes in handy later
                    NSLock().synchronized { [unowned self] in

                        self._lastProductsFetched = productsFetched
                    }

                    // debugging loop to check duplicates (versus direct assignment)
                    for productItem in productsFetched.products {

                        // sanity check
                        if let dupItem = newProducts.filter({ $0.id == productItem.id }).first {

                            // duplicate in this list
                            print("duplicate item in this server call, id= \(dupItem.id)")
                        }
                        if let dupItem = self._products.filter({ $0.id == productItem.id }).first {

                            // duplicate in existing list
                            print("duplicate item in existing list, id=: \(dupItem.id)")
                        }
                        newProducts.append(productItem)
                    }
//                    newProducts = productsFetched.products
                }
                else {

                    returnError = ApiError.badHttpStatus(reason: "\(productsFetched.status)")
                }
            }
            catch {

                print(error.localizedDescription)
                returnError = error
            }

            // append new products on running products
            if returnError == nil && newProducts.count > 0 {

                NSLock().synchronized { [unowned self] in

                    self._products.append(contentsOf: newProducts)
                }
            }

            // inform caller
            completionHandler(returnError, newProducts)
        }
    }
}
