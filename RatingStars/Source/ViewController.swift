//
//  ViewController.swift
//  RatingStars
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private struct Constants {

        static let tagSingleStar = 10
        static let tagMultiStars = 11
    }

    @IBOutlet weak var ratingStarView: RatingStarView!
    @IBOutlet weak var ratingStarsView: RatingStarsView!
    @IBOutlet weak var percentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // identify and wire up as delegate
        ratingStarView.tag = Constants.tagSingleStar
        ratingStarView.delegate = self

        // let control track it's tap percent
        ratingStarView.tapToSetPercent = true

        // restrict to star area only
        ratingStarView.tapMustBeOnStar = true

        // setup multi-star listening
        ratingStarsView.tag = Constants.tagMultiStars
        ratingStarsView.delegate = self
    }

    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        super.touchesBegan(touches, with: event)
    //
    //        // update label
    //        percentLabel.text = String(format: "%0.1f%%", ratingStarView.percentFill * 100)
    //    }
}

extension ViewController: RatingStarsViewDelegate {

    func percentUpdated(ratingStarsView: RatingStarsView, percentFill: CGFloat) {

        let percentText = String(format: "%0.1f%%", percentFill * 100)
        print("ID: \(ratingStarsView.tag) update to \(percentText)")
    }
}

extension ViewController: RatingStarViewDelegate {

    func percentUpdated(ratingStarView: RatingStarView, percentFill: CGFloat) {

        let percentText = String(format: "%0.1f%%", percentFill * 100)
        print("ID: \(ratingStarView.tag) update to \(percentText)")

        // update label
        percentLabel.text = percentText

        //        let usePercent = false
        //        if usePercent {
        //
        //            // pass along to stars via percent
        //            ratingStarsView.percentFill = percentFill
        //        }
        //        else {

        // pass along to stars via rank
        let rank = percentFill * CGFloat(ratingStarsView.numStars)
        ratingStarsView.rankingFill = rank
        //        }
    }
}
