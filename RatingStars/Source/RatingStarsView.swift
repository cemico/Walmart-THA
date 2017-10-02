//
//  RatingStarsView.swift
//  RatingStarsView
//
//  Created by Dave Rogers on 9/30/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

protocol RatingStarsViewDelegate {

    // simple communication agent of change
    func percentUpdated(ratingStarsView: RatingStarsView, percentFill: CGFloat)
}

@IBDesignable
class RatingStarsView: UIView {

    //
    // Constants
    //

    struct Constants {

        struct Defaults {

            static let numberOfStars = UInt(5)

            static let starBeginningTag = 100
        }
    }
    
    //
    // Variables / Properties (private)
    //

    // backing for the individual rating stars
    private var stars: [RatingStarView] = []

    // percent filled - changed from didSet as early bug with Swift 4 not reliably updating
    private var _percentFill = RatingStarView.Constants.Defaults.percentFill

    // block updates flag
    private var _isUpdating = false

    //
    // Variables / Properties (public)
    //

    // optional means to communicate change
    var delegate: RatingStarsViewDelegate? = nil

    @IBInspectable var numStars: UInt = Constants.Defaults.numberOfStars {

        didSet {

            // update if changed
            if oldValue != numStars {

                update()
            }
        }
    }

    // note: must specify type to show up in IB
    @IBInspectable var borderColor: UIColor = RatingStarView.Constants.Defaults.borderColor {

        didSet {

            // update if changed
            if oldValue != borderColor {

                update()
            }
        }
    }

    // note: must specify type to show up in IB
    @IBInspectable var filledColor: UIColor = RatingStarView.Constants.Defaults.filledColor {

        didSet {

            // update if changed
            if oldValue != filledColor {

                update()
            }
        }
    }

    // percentage expressed as 0-1
    var percentFill: CGFloat {

        get {

            return _percentFill
        }

        set {

            // validate, percent 0 <= xx <= 1
            let newPercentFill = newValue.constrainTo(min: 0, max: 1)

            // udpate if changed
            if _percentFill != newPercentFill {

                // update
                _percentFill = newPercentFill

                // optional listener notification
                delegate?.percentUpdated(ratingStarsView: self, percentFill: _percentFill)

                // update
                update()
            }
        }
    }

    // value of xx/numStars, like 3.5 of 5 stars
    var rankingFill: CGFloat = 0 {

        didSet {

            var newPercentFill = CGFloat(0)

            // validate and pass through to percent fill
            if rankingFill < 0 || stars.count <= 0 {

                newPercentFill = 0
            }
            else if rankingFill > CGFloat(stars.count) {

                newPercentFill = 1
            }
            else {

                newPercentFill = rankingFill / CGFloat(stars.count)
            }

            // update if changed
            if newPercentFill != percentFill {

                percentFill = newPercentFill
            }
        }
    }

    // allow for block updates, set true to start, false to end
    var isUpdating: Bool {

        get {

            return _isUpdating
        }

        set {

            _isUpdating = newValue

            if !newValue {

                update()
            }
        }
    }
}

extension RatingStarsView {

    //
    // System overrides
    //

    override func layoutSubviews() {
        super.layoutSubviews()

        // keep positions in sync
        update()
    }
}

extension RatingStarsView {

    //
    // Private helpers
    //

    private func update() {

        if !isUpdating {

            // bring counts in sync
            syncStarsCount()

            // update current stars to current properties
            updateStars()

            // redraw
            self.setNeedsDisplay()
        }
    }

    private func syncStarsCount() {

//        // testing
//        let colors: [UIColor] = [.orange, .red, .yellow, .green, .magenta, .brown, .cyan]

        // assumption
        guard numStars != stars.count else { return }

        // need to reduce stars to match count
        let numberOfStars = Int(numStars)

        if numStars > stars.count {

            // need to create new stars to match count
            let numberToCreate = numberOfStars - stars.count
            var nextTag = Constants.Defaults.starBeginningTag + stars.count
            for _ in 1 ... numberToCreate {

                // create
                let star = RatingStarView()

//                // testing
//                star.backgroundColor = colors[stars.count % colors.count]

                // identify
                star.tag = nextTag
                nextTag += 1

                // wire in for updates
                star.tapToSetPercent = false
//                star.tapMustBeOnStar = true
//                star.delegate = self

                // add
                addSubview(star)
                stars.append(star)
            }
        }
        else {

            // get array to release
            let releaseStars = Array(stars[numberOfStars...])

            // trim current array to match
            stars = Array(stars[..<numberOfStars])

            // clear view hierarchy
            releaseStars.forEach({ $0.removeFromSuperview() })
        }
    }

    private func updateStars() {

        // placement best fit logic
        positionStars()

        // update stars properties
        syncStarProperties()

        // fill state from percentage
        syncStarProgress()
    }

    private func syncStarProperties() {

        for star in stars {

            // block update properties
            star.isUpdating = true
            star.borderColor = borderColor
            star.filledColor = filledColor
            star.isUpdating = false
        }
    }

    private func syncStarProgress() {

        let oneStarFullProgress: CGFloat = 1.0 / CGFloat(numStars)
        var previousFullOn: CGFloat = 0
        for (index, star) in stars.enumerated() {

            // 3 possible states, full on, partial on, off
            let fullOn = CGFloat(index + 1) * oneStarFullProgress
            if percentFill >= fullOn {

                // on
                star.percentFill = 1
            }
            else if previousFullOn < percentFill && percentFill <= fullOn {

                // percent
                star.percentFill = (percentFill - previousFullOn) / oneStarFullProgress
            }
            else {

                // off
                star.percentFill = 0
            }

            // udpate
            previousFullOn = fullOn
        }
    }

    private func positionStars() {

        // determine best fit size
        let numberOfStars = CGFloat(stars.count)
        let heightPerItem = frame.size.height
        let widthPerItem  = frame.size.width / numberOfStars
        let bestPerItemSize = min(widthPerItem, heightPerItem)

        // determine equal spacing inbetween each star, i.e. one less than star count
        var widthSpacing = CGFloat(0)
        let minimumSpaceNeeded = bestPerItemSize * numberOfStars
        let numberOfSpaces = numberOfStars - 1
        if numberOfStars > 1 {

            let spaceAvailable = max(0, frame.size.width - minimumSpaceNeeded)
            widthSpacing = spaceAvailable / numberOfSpaces
        }

        // position in center of height
        let yPos = max(0, (frame.size.height - bestPerItemSize) / 2)

        // split any remainder in space
        var xPos = (frame.size.width - minimumSpaceNeeded - (widthSpacing * numberOfSpaces)) / 2

        // position
        for star in stars {

            // new position
            let rect = CGRect(x: xPos, y: yPos, width: bestPerItemSize, height: bestPerItemSize)

            // sanity check
            if !rect.equalTo(star.frame) {

                star.frame = rect
            }

            // advance to next x pos
            xPos += bestPerItemSize + widthSpacing
        }
    }
}
