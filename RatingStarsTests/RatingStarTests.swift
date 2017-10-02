//
//  RatingStarTests.swift
//  RatingStarTests
//
//  Created by Dave Rogers on 9/30/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import XCTest

class RatingStarTests: XCTestCase {

    struct Constants {

        // sizing
        static let width  = CGFloat(100)
        static let height = CGFloat(100)

        // border widths
        static let borderWidth1 = CGFloat(2)
        static let borderWidth2 = CGFloat(3)

        // border colors
        static let borderColor1 = UIColor.yellow
        static let borderColor2 = UIColor.red

        // empty colors
        static let emptyColor1 = UIColor.orange
        static let emptyColor2 = UIColor.purple

        // fill colors
        static let fillColor1 = UIColor.magenta
        static let fillColor2 = UIColor.blue

        // percent fills
        static let percentFillUnderrun = CGFloat(-1)
        static let percentFillOverrun  = CGFloat(5)
        static let percentFillNone     = CGFloat(0)
        static let percentFillFull     = CGFloat(1)
        static let percentFill25       = CGFloat(0.25)
        static let percentFill75       = CGFloat(0.75)

        // custom points
        static let pathPoints: [CGPoint] = [

            // test triangle
            CGPoint(x: 0.05,    y: 0.05),
            CGPoint(x: 0.95,    y: 0.05),
            CGPoint(x: 0.95,    y: 0.95)
        ]
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBorderWidth() {

        // clean start
        let ratingStarView = RatingStarView()

        // ability to set border width and positive test
        ratingStarView.borderWidth = Constants.borderWidth1
        XCTAssert(ratingStarView.borderWidth == Constants.borderWidth1, "Border width positive test failure")

        // ability to change border color and negative test
        ratingStarView.borderWidth = Constants.borderWidth2
        XCTAssert(ratingStarView.borderWidth != Constants.borderWidth1, "Border width negative test failure")
        XCTAssert(ratingStarView.borderWidth == Constants.borderWidth2, "Border width change test failure")
    }

    func testBorderColor() {

        // clean start
        let ratingStarView = RatingStarView()

        // ability to set border color and positive test
        ratingStarView.borderColor = Constants.borderColor1
        XCTAssert(ratingStarView.borderColor == Constants.borderColor1, "Border color positive test failure")

        // ability to change border color and negative test
        ratingStarView.borderColor = Constants.borderColor2
        XCTAssert(ratingStarView.borderColor != Constants.borderColor1, "Border color negative test failure")
        XCTAssert(ratingStarView.borderColor == Constants.borderColor2, "Border color change test failure")
    }

    func testEmptyColor() {

        // clean start
        let ratingStarView = RatingStarView()

        // ability to set empty color and positive test
        ratingStarView.emptyColor = Constants.emptyColor1
        XCTAssert(ratingStarView.emptyColor == Constants.emptyColor1, "Empty color positive test failure")

        // ability to change border color and negative test
        ratingStarView.emptyColor = Constants.emptyColor2
        XCTAssert(ratingStarView.emptyColor != Constants.emptyColor1, "Empty color negative test failure")
        XCTAssert(ratingStarView.emptyColor == Constants.emptyColor2, "Empty color change test failure")
    }

    func testFillColor() {

        // clean start
        let ratingStarView = RatingStarView()

        // ability to set fill color and positive test
        ratingStarView.filledColor = Constants.fillColor1
        XCTAssert(ratingStarView.filledColor == Constants.fillColor1, "Fill color positive test failure")

        // ability to change border color and negative test
        ratingStarView.filledColor = Constants.fillColor2
        XCTAssert(ratingStarView.filledColor != Constants.fillColor1, "Fill color negative test failure")
        XCTAssert(ratingStarView.filledColor == Constants.fillColor2, "Fill color change test failure")
    }

    func testPercentFill() {

        // clean start - needs frame as view has internal bounds checking
        let ratingStarView = RatingStarView(frame: CGRect(x: 0, y: 0, width: Constants.width, height: Constants.height))

        // boundary checks, underrun and overrun
        ratingStarView.percentFill = Constants.percentFillUnderrun
        XCTAssert(ratingStarView.percentFill == Constants.percentFillNone, "Percent Fill Underrun failure")
        ratingStarView.percentFill = Constants.percentFillOverrun
        XCTAssert(ratingStarView.percentFill == Constants.percentFillFull, "Percent Fill Overrun failure")

        // edge checks, min max edges
        ratingStarView.percentFill = Constants.percentFillNone
        XCTAssert(ratingStarView.percentFill == Constants.percentFillNone, "Percent Fill Min Edge failure")
        ratingStarView.percentFill = Constants.percentFillFull
        XCTAssert(ratingStarView.percentFill == Constants.percentFillFull, "Percent Fill Max Edge failure")

        // non-edge checks
        ratingStarView.percentFill = Constants.percentFill25
        XCTAssert(ratingStarView.percentFill == Constants.percentFill25, "Percent Fill Non-Edge 25 failure")
        ratingStarView.percentFill = Constants.percentFill75
        XCTAssert(ratingStarView.percentFill == Constants.percentFill75, "Percent Fill Non-Edge 75 failure")
    }

    func testPixelFill() {

        // clean start - needs frame to test pixel percents
        let ratingStarView = RatingStarView(frame: CGRect(x: 0, y: 0, width: Constants.width, height: Constants.height))

        // setup - keep on even boundaries if width to avoid precision errors
        let zeroWidth = CGFloat(0)
        let fullWidth = ratingStarView.frame.size.width
        let halfWidth = fullWidth / 2
        let halfFullPercent = Constants.percentFillFull / 2
        let zeroFullPercent = Constants.percentFillNone
        let allFullPercent = Constants.percentFillFull

        // 0% test
        ratingStarView.pixelFill = zeroWidth
        XCTAssert(ratingStarView.percentFill == zeroFullPercent, "Pixel Fill 0% width failure")

        // 50% test
        ratingStarView.pixelFill = halfWidth
        XCTAssert(ratingStarView.percentFill == halfFullPercent, "Pixel Fill 50% width failure")

        // 100% test
        ratingStarView.pixelFill = fullWidth
        XCTAssert(ratingStarView.percentFill == allFullPercent, "Pixel Fill 100% width failure")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
