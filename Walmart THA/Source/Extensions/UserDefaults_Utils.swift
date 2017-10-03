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

            static let currentFileID = "currentFileID"
        }

        struct Defaults {

            static let fileIDSeed   = 100
        }
    }

    var nextFileID: Int {

        // default
        var nextID = Constants.Defaults.fileIDSeed

        // check if saved value exists
        let key = Constants.Keys.currentFileID

        // return 0 if not found
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
