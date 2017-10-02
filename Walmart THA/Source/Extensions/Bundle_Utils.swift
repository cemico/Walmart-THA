//
//  Bundle_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Bundle {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        static let badApiKey = "badApiKey"
    }
    
    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    enum InfoItemTypes: String {

        case walmartApiKey = "WalmartApiKey"
    }

    ///////////////////////////////////////////////////////////
    // class level properties
    ///////////////////////////////////////////////////////////

    // lookup key from info.plist's build-time population from build definitions
    // (which allows different keys for different build targets, say if
    //  you wanted a test key and prod key for debug and release)
    static var walmartApiKey: String {

        var keyValue = Constants.badApiKey
        if let value = Bundle.main.stringInfoValue(for: .walmartApiKey) {

            keyValue = value
        }
        else {

            print("Check info.plist and user defined build constants for the definition of key: \(Bundle.InfoItemTypes.walmartApiKey.rawValue)")
        }

        return keyValue
    }

    ///////////////////////////////////////////////////////////
    // extended functions
    ///////////////////////////////////////////////////////////

    func stringInfoValue(for key: InfoItemTypes) -> String? {

        if let value: String = Bundle.main.infoValueOfType(for: key) {

            return value
        }

        return nil
    }

    // convience wrapper to extrat info.plist values
    func infoValueOfType<T>(for key: InfoItemTypes) -> T? {

        // unwrap info dict
        guard let infoDict = infoDictionary else { return nil }

        // unwrap type
        guard let value = infoDict[key.rawValue] as? T else { return nil }

        return value
    }
}

