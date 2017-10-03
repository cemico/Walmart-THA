//
//  CacheManager.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/3/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

class CacheManager {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        static let imageFilenamePrefix  = "image"
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let shared = CacheManager()

    // image map to file cache
    private var imageMap: [String : Any] = [:]

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private init() {

        print("\(String.className(ofSelf: self)).\(#function)")
    }

    ///////////////////////////////////////////////////////////
    // api - map level
    ///////////////////////////////////////////////////////////

    func clear() {

        NSLock().synchronized { [unowned self] in

            // clear local and file copies
            self.imageMap = [:]
            _ = self.save()
        }
    }

    func load() {

        // file-based load
        imageMap = FileManager.default.readFile(fileType: .images)
    }

    func save() -> Bool {

        // file-based save
        let success = FileManager.default.writeFile(fileType: .images, dict: imageMap)
        print("Image cache updated: \(success), \(imageMap.count) items")
        return success
    }

    ///////////////////////////////////////////////////////////
    // api - item level
    ///////////////////////////////////////////////////////////

    func clearImage(url: String) {

        // check if exists
        guard let filename = imageMap[url] as? String else { return }

        // clear
        imageMap[url] = nil

        // save new map
        if save() {

            // clear old filename
            _ = FileManager.default.deleteImage(filename: filename)
        }
    }

    func loadImage(url: String) -> UIImage? {

        // translate url into file's filename
        guard let filename = imageMap[url] as? String else { return nil }

        // load
        return FileManager.default.loadImage(filename: filename)
    }

    func saveImage(url: String, image: UIImage) {

        // check if already exists
        guard imageMap[url] == nil else { return }

        // update
        let prefix = Constants.imageFilenamePrefix
        let fileID = UserDefaults.standard.nextFileID
        let ext = url.ext
        let filename = "\(prefix)-\(fileID).\(ext)"

        if FileManager.default.saveImage(filename: filename, image: image) {

            // successfully saved - update cache map
            imageMap[url] = filename

            // save map
            _ = save()
        }
    }
}
