//
//  NSAttributedString_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {

    func height(withConstrainedWidth width: CGFloat) -> CGFloat {

        // figure out height needed to display the attributed string
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.height)
    }

}
