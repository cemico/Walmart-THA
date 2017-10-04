//
//  UIImageView_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/2/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIImageView {

    struct Constants {

        static let placeholderImageName = "loading"
    }

    func loadImageFrom(url: String, contentMode: UIViewContentMode = .scaleAspectFit, placeholderAssetName: String? = Constants.placeholderImageName) {

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

                // nothing to udpate if we've been released
                guard let strongSelf = self else { return }

                // update mode
                strongSelf.contentMode = contentMode

                if let image = image {

                    // update self with new image
                    strongSelf.image = image
                }
                else {

                    // perhaps standard image load failed image
                    // for now - clear placeholder
                    strongSelf.image = nil // UIImage.init(name: "imageLoadFailed")
                }
            }
        }
    }
}
