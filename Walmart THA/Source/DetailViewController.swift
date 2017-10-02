//
//  DetailViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionTextView: UITextView!
    @IBOutlet weak var detailProductImageView: UIImageView!

    func configureView() {

        // Update the user interface for the detail item.
        if let detail = detailItem {

            if let tv = detailDescriptionTextView {

                tv.text = "\(detail.description)"
            }

            if let iv = detailProductImageView {

                iv.loadImageFrom(url: detail.imageUrl)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: ProductItem? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

