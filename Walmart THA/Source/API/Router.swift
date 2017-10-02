//
//  Router.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

//
// type safe URL routes router enum model
//

enum Router {

    //
    // constants
    //

    struct Constants {

        struct HttpStatus {

            // success
            static let ok = 200
        }

        struct Api {

            // note: loose documentation ... with a few surprises to keep things interesting
            //       https://walmartlabs-test.appspot.com/

            // maximum number of records server responds
            static let maxServerReturn = 30

            // base
            static let baseURL = "https://walmartlabs-test.appspot.com/_ah/api/walmart"

            // versions
            struct Versions {

                static let v1       = "v1"
                static let current  = Versions.v1
            }

            // endpoints
            struct EndPoints {

                static let products = "walmartproducts"
            }

            struct Keys {

                struct getPartialProductList {

                    static let start = "start"
                    static let count = "count"
                }
            }

            struct Defaults {

                struct getPartialProductList {

                    static let start = 1
                    static let count = 25
                }
            }
        }
    }

    //
    // router enums
    //

    // each case can have various arguments if IDs and such need to be passed in

    // int1 = product record number
    // int2 = number of products for this page
    // ex) key = "start",  1, 20 = start at  1st product and return 20 products, i.e.  1-20
    // ex) key = "count", 61, 20 = start at 61st product and return 20 products, i.e. 61-80
    // note: defaults exist if either/both keys are missing
    case getPartialProductList([String : Any])

    //
    // support enums
    //

    private enum HttpMethod: String {

        // note: Swift 4 auto conversion of rawValue to enum value if no specific value is set
        case GET, POST, PUT, DELETE
    }

    //
    // error enum
    //

    enum RouterErrors: Error {

        case unableToCreateURL
    }

    //
    // internal request type enum
    //

    private enum EncodeRequestType {

        case url, none
    }

    //
    // computed properties
    //

    static var baseURLString: String = {

        return "\(Constants.Api.baseURL)/\(Constants.Api.Versions.current)"
    }()

    var method: String {

        switch self {

            case .getPartialProductList:
                return HttpMethod.GET.rawValue
        }
    }

    var path: String {

        switch self {

            case .getPartialProductList(let parameters):

                // extract and validate optional parameters
                var productStart = Constants.Api.Defaults.getPartialProductList.start
                if let newStart = parameters[Constants.Api.Keys.getPartialProductList.start] as? Int,
                    newStart > 0, newStart != productStart {

                    // use parameter start
                    productStart = newStart
                }
                var productCount = Constants.Api.Defaults.getPartialProductList.count
                if let newCount = parameters[Constants.Api.Keys.getPartialProductList.count] as? Int,
                    newCount > 0, newCount <= Constants.Api.maxServerReturn, newCount != productCount {

                    // use parameter count
                    productCount = newCount
                }

                // /walmartproducts/{apiKey}/{pageNumber}/{pageSize}
                let endpoint = Constants.Api.EndPoints.products
                let apiKey = Bundle.walmartApiKey
                let pageNumber = productStart
                let pageSize = productCount

                // return relative path
                return "\(endpoint)/\(apiKey)/\(pageNumber)/\(pageSize)"
        }
    }

    func asURLRequest() throws -> URLRequest {

        // setup URL
        guard let URL = Foundation.URL(string: Router.baseURLString) else {

            throw RouterErrors.unableToCreateURL
        }

        // setup physical request
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method

        // good place to add any headers if needed
//        mutableURLRequest.setValue(value, forHTTPHeaderField: key)

        // provide any parameter encoding if needed
        switch self {

            // url encoding, i.e. key1=value1&key2=value2 ...
//            case .getSomething(let parameters):
//                return encodeRequest(mutableURLRequest, requestType: .url, parameters: parameters)

            default:
                return encodeRequest(mutableURLRequest, requestType: .none)
        }
    }

    func asURL() throws -> URL {

        do {

            // reuse existing framework to get fully composed url
            let urlRequest = try asURLRequest()
            if let url = urlRequest.url {

                return url
            }
        }
        catch {

            print("ERROR \(#function): \(error)")
        }

        // error mapping
        throw RouterErrors.unableToCreateURL
    }

    //
    // private helpers
    //

    private func encodeRequest(_ mutableURLRequest: URLRequest,
                               requestType: EncodeRequestType,
                               parameters: [String:Any]? = nil) -> URLRequest {

        // sanity check that encoding parameters exist
        guard let parameters = parameters, parameters.count > 0 else { return mutableURLRequest }
        guard let urlOriginal = mutableURLRequest.url else { return mutableURLRequest }

        // default
        var encodedMutableURLRequest = mutableURLRequest

        // encode requested data
        switch requestType {

            case .url:
                var urlComps = URLComponents(url: urlOriginal, resolvingAgainstBaseURL: false)
                let queryItems = parameters.map({ return URLQueryItem(name: "\($0.key)", value: "\($0.value)") })
                urlComps?.queryItems = queryItems
                encodedMutableURLRequest.url = urlComps?.url

            case .none:
                // no encoding - use passed in mutableURLRequest
                break
        }

        if let url = encodedMutableURLRequest.url {

            print("URL: \(url)")
        }

        return encodedMutableURLRequest
    }
}
