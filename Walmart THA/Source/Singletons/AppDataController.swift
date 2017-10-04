//
//  AppDataController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

class AppDataController {

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let shared = AppDataController()

    // local memory store for images
    private var imageCache: [String : UIImage] = [:]

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private init() {

        print("\(String.className(ofSelf: self)).\(#function)")
    }

    ///////////////////////////////////////////////////////////
    // api
    ///////////////////////////////////////////////////////////

    func loadCache() {

        // loads any cache items - on demand caching of memory items
        CacheManager.shared.loadAll()
    }

    func clearCache() {

        // clear cache from disc and memory
        NSLock().synchronized { [unowned self] in

            // memory
            self.imageCache.removeAll()

            // decided to keep products cache only on file, i.e. no memory

            // file
            CacheManager.shared.clearAll()
        }
    }

    func loadImage(url: String, completionHandler: @escaping ((UIImage?) -> Void))  {

        // check memory cache
        if let image = imageCache[url] {

            // valid image
            completionHandler(image)
            return
        }

        // check file cache (on demand load)
        if let image = CacheManager.shared.loadImage(url: url) {

            // save in memory
            imageCache[url] = image
            completionHandler(image)
            return
        }

        // load online and cache - validate url
        guard let imageUrl = URL(string: url) else { completionHandler(nil); return }

        // setup download
        let task = URLSession.shared.dataTask(with:imageUrl) { [unowned self] (data, response, error) in

            if let data = data {

                // successfully downloaded image data
                let image = UIImage(data: data)
                completionHandler(image)

                // save in memory cache
                self.imageCache[url] = image

                // save in file cache
                if let image = image {

                    CacheManager.shared.saveImage(url: url, image: image)
                }
                return
            }

            // issue
            if let error = error {

                print(error.localizedDescription)
            }
            else {

                print("No image data")
            }

            // unable to download image
            completionHandler(nil)
        }

        // start download
        task.resume()
    }
}
