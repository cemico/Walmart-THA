//
//  RatingStarView.swift
//  RatingStar
//
//  Created by Dave Rogers on 9/29/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

protocol RatingStarViewDelegate {

    // simple communication agent of change
    func percentUpdated(ratingStarView: RatingStarView, percentFill: CGFloat)
}

@IBDesignable
class RatingStarView: UIView {

    //
    // Constants
    //

    struct Constants {

        struct Defaults {

            // initial percent fill percentage
            static let percentFill = CGFloat(1)

            // line width for the border of the star
            static let borderWidth = CGFloat(1)

            // line border color
            static let borderColor = UIColor.black

            // inner colors for ratings
            static let emptyColor = UIColor.clear
            static let filledColor = UIColor.blue

            // points which comprise the star's path
            static let pathPoints: [CGPoint] = [

                // symmetrical star points based on a unit space of 1x1
                CGPoint(x: 0.62723,     y: 0.37309),
                CGPoint(x: 0.5,         y: 0.025),
                CGPoint(x: 0.37292,     y: 0.37309),
                CGPoint(x: 0.025,       y: 0.39112),
                CGPoint(x: 0.30504,     y: 0.62908),
                CGPoint(x: 0.20642,     y: 0.975),
                CGPoint(x: 0.5,         y: 0.78265),
                CGPoint(x: 0.79358,     y: 0.975),
                CGPoint(x: 0.69501,     y: 0.62908),
                CGPoint(x: 0.975,       y: 0.39112)
            ]
        }
    }

    //
    // Variables / Properties (private)
    //

    // star path points
    private var _pathPoints = Constants.Defaults.pathPoints
    private var _scaledPathPoints: [CGPoint] = []

    // customized path backing
    private var _starPath: UIBezierPath? = nil

    // current layers
    private var _starLayerEmpty: CALayer? = nil {

        didSet {

            // clear the old
            oldValue?.removeFromSuperlayer()
        }
    }
    private var _starLayerFilled: CALayer? = nil {

        didSet {

            // clear the old
            oldValue?.removeFromSuperlayer()
        }
    }
    private lazy var _starLayerFilledMask: CALayer = {

        let maskLayer = CALayer()
        maskLayer.opacity = 1
        maskLayer.frame = self.bounds
        maskLayer.backgroundColor = UIColor.black.cgColor

        // save original size as we'll update this mask
        // based on percentage complete / ranking percentage
        _starLayerFilledMaskRect = maskLayer.frame

        // set to current progress
        maskLayer.frame.size.width = _starLayerFilledMaskRect.size.width * _percentFill

        return maskLayer
    }()

    // identity size for filled mask layer
    private var _starLayerFilledMaskRect = CGRect()

    // block updates flag
    private var _isUpdating = false

    // percent filled - changed from didSet as early bug with Swift 4 not reliably updating
    private var _percentFill = Constants.Defaults.percentFill

    //
    // Variables / Properties (public)
    //

    // flag to have control auto-set it's percentage based on tap location
    var tapToSetPercent = false

    // flag for auto-setting, limiting tap area to star region
    var tapMustBeOnStar = false

    // optional means to communicate change
    var delegate: RatingStarViewDelegate? = nil

    // percentage via number of pixels of max width
    var pixelFill: CGFloat {

        get {

            return self.frame.size.width * _percentFill
        }

        set {

            // validate
            let value = max(0, min(newValue, frame.size.width))

            // create percentage of pixels within frame
            let newPercentFill = value / self.frame.size.width

            // update if changed
            if percentFill != newPercentFill {

                percentFill = newPercentFill
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

            // update if changed
            if _percentFill != newPercentFill {

                // save
                _percentFill = newPercentFill

                // optional listener notification
                delegate?.percentUpdated(ratingStarView: self, percentFill: _percentFill)

                // update
                update()
            }
        }
    }

    // stroke width
    var borderWidth = Constants.Defaults.borderWidth {

        didSet {

            // update if changed
            if oldValue != borderWidth {

                // update
                update()
            }
        }
    }

    // note: must specify type to show up in IB
    @IBInspectable var borderColor: UIColor = Constants.Defaults.borderColor {

        didSet {

            // udpate if changed
            if oldValue != borderColor {

                // udpate
                update()
            }
        }
    }

    // note: must specify type to show up in IB
    @IBInspectable var filledColor: UIColor = Constants.Defaults.filledColor {

        didSet {

            // udpate if changed
            if oldValue != filledColor {

                // update
                update()
            }
        }
    }

    // fill color of empty state, typically clear
    var emptyColor = Constants.Defaults.emptyColor {

        didSet {

            // udpate if changed
            if oldValue != emptyColor {

                // update
                update()
            }
        }
    }

    // bezier points to constnruct shape
    var pathPoints: [CGPoint] {

        get {

            return _scaledPathPoints
        }

        set {

            // udpate if changed
            if _pathPoints != newValue {

                // save new points and scale
                _pathPoints = newValue
                _scaledPathPoints = scaleToFrame()

                // update
                update()
            }
        }
    }

    // path from current bezier points
    var starPath: UIBezierPath {

        get {

            // allow for custom paths to be set, otherwise use default star path
            if let path = _starPath {

                // custom path
                return path
            }

            // create path based on points
            let path = UIBezierPath()
            guard let moveToPoint = pathPoints.first else { return path }

            // start
            path.move(to: moveToPoint)

            // connecting points
            if pathPoints.count > 1 {

                // lines to remaining points, utilize Swift 4 range and slice handling
                let linePoints = pathPoints[1...]
                for linePoint in linePoints {

                    path.addLine(to: linePoint)
                }
            }

            // connect last point to start point
            path.close()

            // save
            _starPath = path
            return path
        }

        set {

            // custom path being set to override path points - save,
            // or cleared to use default path points again
            _starPath = newValue

            // update
            self.setNeedsDisplay()
        }
    }

    // bottom layer which is empty
    var emptyLayer: CALayer {

        // check cache
        if let emptyLayer = _starLayerEmpty {

            return emptyLayer
        }

        // create path based layer for our star
        let layer = createStarLayer(fillColor: emptyColor)
//        layer.backgroundColor = filledColor.withAlphaComponent(0.1).cgColor
        self.layer.addSublayer(layer)
        _starLayerEmpty = layer

        return layer
    }

    // top layer which is full, yet masked off to some percentage
    var filledLayer: CALayer {

        // check cache
        if let filledLayer = _starLayerFilled {

            return filledLayer
        }

        // create path based layer for our star
        let layer = createStarLayer(fillColor: filledColor)
        self.layer.addSublayer(layer)
        _starLayerFilled = layer

        // associate our mask over our filled star
        layer.mask = _starLayerFilledMask

        return layer
    }

    // allow for block updates, set true to start, false to end
    var isUpdating: Bool {

        get {

            return _isUpdating
        }

        set {

            _isUpdating = newValue

            // block updates - single display update
            if !newValue {

                // kickoff end of block update when updating return to false
                update()
            }
        }
    }
}

extension RatingStarView {

    //
    // System overrides
    //

    override var frame: CGRect {

        didSet {

            if !frame.equalTo(oldValue) {

                // frame changed - update to new scale
                _scaledPathPoints = scaleToFrame()

                // update
                update()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // mask represents the percent change - only thing that is updated, keep in sync
        let maskWidth = _starLayerFilledMaskRect.size.width * _percentFill
        if _starLayerFilledMask.frame.size.width != maskWidth {

            _starLayerFilledMask.frame.size.width = maskWidth
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        // act on first touch, versus say tracking and/or at last touch
        defer {

            // super called last so it has access to the most current percent value
            super.touchesBegan(touches, with: event)
        }

        // since we have defer setup, simple guard / return checking
        guard let touch = touches.first else { return }
        let pt = touch.location(in: self)

        // optionally check for self-setting tap percentage
        guard tapToSetPercent else { return }

        // optionally restrict touch to star only
        if tapMustBeOnStar {

            guard starPath.contains(pt) else { return }
        }

        // track auto-tap for percent
        let maxWidth = self.frame.size.width

        var percent = CGFloat(1)
        if pt.x <= 0 || maxWidth <= 0 {

            percent = 0
        }
        else if pt.x >= maxWidth {

            percent = 1
        }
        else {

            percent = pt.x / maxWidth
        }

        // update
        self.percentFill = percent
    }
}

extension RatingStarView {

    //
    // Private helpers
    //

    private func update() {

        if !isUpdating {

            // clear out the old
            _starPath = nil
            _starLayerEmpty = nil
            _starLayerFilled = nil

            // reset to the new
            _ = starPath
            _ = emptyLayer
            _ = filledLayer

            // as we are using layers, update layout if not block updating
            self.setNeedsLayout()
        }
    }

    private func scaleToFrame() -> [CGPoint] {

        // based on 1:1, get new size
        let size = self.frame.size

        // update point ratio per the current container size
        let scaledPoints = _pathPoints.map { point in

            return CGPoint(

                x: point.x * size.width  + borderWidth,
                y: point.y * size.height + borderWidth
            )
        }

        return scaledPoints
    }

    private func createStarLayer(fillColor: UIColor) -> CALayer {

        // create path based layer for our star
        let layer = CAShapeLayer()

        // setup for possible rotation from center
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // sync scale
        layer.contentsScale = UIScreen.main.scale

        // borders/colors
        layer.strokeColor = borderColor.cgColor
        layer.lineWidth = borderWidth
        layer.fillColor = fillColor.cgColor

        // track view size
        layer.frame.size = self.bounds.size
        layer.masksToBounds = true

        // set object path
        layer.path = starPath.cgPath
        layer.isOpaque = true

        return layer
    }
}
