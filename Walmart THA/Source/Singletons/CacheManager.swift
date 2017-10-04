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

        static let imageFilenamePrefix   = "image"
        static let productsFetchedFilenamePrefix = "productFetched"
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let shared = CacheManager()

    // image maps to file cache
    private var imageMap: [String : Any] = [:]
    private var productsFetchedMap: [String : Any] = [:]

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private init() {

        print("\(String.className(ofSelf: self)).\(#function)")
    }

    ///////////////////////////////////////////////////////////
    // api - map level
    ///////////////////////////////////////////////////////////

    func clearImages() {

        NSLock().synchronized { [unowned self] in

            // clear local and file copies
            self.imageMap = [:]
            _ = self.saveImages()
        }
    }

    func clearProducts() {

        NSLock().synchronized { [unowned self] in

            // clear local and file copies
            self.productsFetchedMap = [:]
            _ = self.saveProducts()
        }
    }

    func clearAll() {

        clearImages()
        clearProducts()
    }

    func loadAll() {

        // file-based load
        imageMap = FileManager.default.readFile(fileType: .images)
        productsFetchedMap = FileManager.default.readFile(fileType: .products)
    }

    func saveImages() -> Bool {

        // file-based save
        let success = FileManager.default.writeFile(fileType: .images, dict: imageMap)
        print("Image cache updated: \(success), \(imageMap.count) items")
        return success
    }

    func saveProducts() -> Bool {

        // file-based save
        let success = FileManager.default.writeFile(fileType: .products, dict: productsFetchedMap)
        print("Products Fetched cache updated: \(success), \(productsFetchedMap.count) items")
        return success
    }

    func saveAll() -> Bool {

        // file-based save
        let successImages = saveImages()
        let successFetched = saveProducts()
        return successImages && successFetched
    }

    ///////////////////////////////////////////////////////////
    // api - image item level
    ///////////////////////////////////////////////////////////

    func clearImage(url: String) {

        // check if exists
        guard let filename = imageMap[url] as? String else { return }

        // clear
        imageMap[url] = nil

        // save new map
        if saveImages() {

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
        let fileID = UserDefaults.standard.nextImageFileID
        let ext = url.ext
        let filename = "\(prefix)-\(fileID).\(ext)"

        if FileManager.default.saveImage(filename: filename, image: image) {

            // successfully saved - update cache map
            imageMap[url] = filename

            // save map
            _ = saveImages()
        }
    }

    ///////////////////////////////////////////////////////////
    // api - product item level
    ///////////////////////////////////////////////////////////

    func clearProductsFetch(pageNumber: String) {

        // check if exists
        guard let filename = productsFetchedMap[pageNumber] as? String else { return }

        // clear
        productsFetchedMap[pageNumber] = nil

        // save new map
        if saveProducts() {

            // clear old filename
            _ = FileManager.default.deleteProductsFetch(filename: filename)
        }
    }

    func loadProductsFetch(pageNumber: String) -> ProductsFetch? {

        // translate url into file's filename
        guard let filename = productsFetchedMap[pageNumber] as? String else { return nil }

        // load
        return FileManager.default.loadProductsFetch(filename: filename)
    }

    func saveProductsFetch(pageNumber: String, productsFetch: ProductsFetch) {

        // check if already exists
        guard productsFetchedMap[pageNumber] == nil else { return }

        // update
        let prefix = Constants.productsFetchedFilenamePrefix
        let fileID = pageNumber
        let ext = "plist"
        let filename = "\(prefix)-\(fileID).\(ext)"

        if FileManager.default.saveProductsFetch(filename: filename, productsFetch: productsFetch) {

            // successfully saved - update cache map
            productsFetchedMap[pageNumber] = filename

            // save map
            _ = saveProducts()
        }
    }
}
