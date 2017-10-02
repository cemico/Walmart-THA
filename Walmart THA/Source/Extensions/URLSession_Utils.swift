//
//  URLSession_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/2/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

extension URLSession {

    enum URLSessionErrors: Error {

        case noData(reason: String)
    }

    static func dataRequest(request: URLRequest, completionHandler: @escaping ((_ data: Data?, _ error: Error?) -> Void)) {

        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in

            if let data = data {

                completionHandler(data, nil)
            }
            else {

                completionHandler(nil, URLSessionErrors.noData(reason: "No Data"))
            }

        }).resume()
    }
}
