//
//  CGFloat_Utils.swift
//  RatingStarsView
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension CGFloat {

    func constrainTo(min: CGFloat, max: CGFloat) -> CGFloat {

        if self <= min {

            return min
        }
        else if self >= max {

            return max
        }
        else {

            return self
        }
    }
}
