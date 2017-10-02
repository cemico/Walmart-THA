//
//  String_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension String {

    static func className<T>(ofSelf: T) -> String {

        return String(describing: type(of: ofSelf))
    }

    var asUrlEncoded: String {

        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        if let encodedSelf = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {

            return encodedSelf
        }

        return self
    }
}
