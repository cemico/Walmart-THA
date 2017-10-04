//
//  UserDefaults_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/3/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UserDefaults {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        struct Keys {

            static let currentImageFileID   = "currentImageFileID"
            static let currentProductFileID = "currentProductFileID"
        }

        struct Defaults {

            static let fileIDSeed   = 100
        }
    }

    var nextImageFileID: Int {

        // default
        let defaultValue = Constants.Defaults.fileIDSeed

        // check if saved value exists
        let key = Constants.Keys.currentImageFileID

        return nextFileID(key: key, defaultValue: defaultValue)
    }

    var nextProductFileID: Int {

        // default
        let defaultValue = Constants.Defaults.fileIDSeed

        // check if saved value exists
        let key = Constants.Keys.currentProductFileID

        return nextFileID(key: key, defaultValue: defaultValue)
    }

    private func nextFileID(key: String, defaultValue: Int) -> Int {

        // default
        var nextID = defaultValue

        // check if saved value exists
        // returns 0 if not found
        let currentValue = self.integer(forKey: key)
        if currentValue > 0 {

            // bump to next id value
            nextID = currentValue + 1
        }

        // save
        self.set(nextID, forKey: key)
        self.synchronize()

        return nextID
    }
}
