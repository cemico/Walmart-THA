//
//  String_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

extension String {

    private struct Constants {

        static let maxUnicodeValueToShow    = 256
        static let spaceUnicodeValue        = UInt16(32)
    }

    static func className<T>(ofSelf: T) -> String {

        return String(describing: type(of: ofSelf))
    }

    static func from(any: Any, default value: String = "") -> String {

        return any as? String ?? value
    }

    var asUrlEncoded: String {

        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        if let encodedSelf = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {

            return encodedSelf
        }

        return self
    }

    var ext: String {

        let nsSelf = self as NSString
        return nsSelf.pathExtension
    }

    func stringByAppendingPathComponent(path: String) -> String {

        let nsSelf = self as NSString
        return nsSelf.appendingPathComponent(path)
    }

    var html2AttributedString: NSAttributedString? {

        let stripped = self.withoutUnicodeChars
        guard let data = stripped.data(using: String.Encoding.utf8) else { return nil }
        do {
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)
            return attributedString
        }
        catch  {
            print(error.localizedDescription)
            return  nil
        }
    }

    var html2String: String {

        return html2AttributedString?.string ?? ""
    }

//    func removeCharsIn(set: CharacterSet) -> String {
//
////        let charsToRemove = set.inverted
//        let components = self.components(separatedBy: set)
//        return components.joined(separator: "")
//    }

    init?(utf16chars: [UInt16]) {

        // onstruct string from array of utf16 uint values
        var str = ""
        var generator = utf16chars.makeIterator()
        var utf16 : UTF16 = UTF16()
        var done = false

        while !done {

            let r = utf16.decode(&generator)
            switch (r) {

                case .emptyInput:
                    done = true
                case let .scalarValue(val):
                    str.append(Character(val))
                case .error:
                    return nil
            }
        }
        self = str
    }

    var withoutUnicodeChars: String {

//        let validCharSet = CharacterSet.alphanumerics.intersection(CharacterSet.punctuationCharacters)
//        return removeCharsIn(set: validCharSet)

        // no stripping if equal
        guard count != utf8.count else { return self }

        // simple data clense
        var utf16array: [UInt16] = []
        let inputArray = Array(self.utf16)
        for (index, utf16) in inputArray.enumerated() {

            if utf16 <= Constants.maxUnicodeValueToShow {

                // good char
                utf16array.append(utf16)
                continue
            }

            // check if multiple are consecutive, only replace as one space
            if index + 1 < inputArray.count {

                if inputArray[index + 1] > Constants.maxUnicodeValueToShow {

                    // skip this one, another one follows behind it
                    continue
                }
            }

            // strip out unicode upper characters by replacing with space
            utf16array.append(Constants.spaceUnicodeValue)
        }

        return String(utf16chars: utf16array) ?? self
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
