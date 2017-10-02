//
//  UIImageView_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/2/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIImageView {

    func loadImageFrom(url: String, contentMode: UIViewContentMode = .scaleAspectFit, placeholderAssetName: String? = nil) {

        // check for placeholder
        if let placeHolder = placeholderAssetName,
            let image = UIImage.init(named: placeHolder) {

            DispatchQueue.main.async { [weak self] in

                self?.image = image
            }
        }

        // download image data
        AppDataController.shared.loadImage(url: url) { image in

            DispatchQueue.main.async { [weak self] in

                // update mode
                self?.contentMode = contentMode

                if let image = image {

                    // update self with new image
                    self?.image = image
                }
                else {

                    // perhaps standard image load failed image
                    // for now - clear placeholder
                    self?.image = nil // UIImage.init(name: "imageLoadFailed")
                }
            }
        }
    }
}
