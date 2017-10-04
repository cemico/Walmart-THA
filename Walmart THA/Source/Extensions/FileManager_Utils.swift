//
//  FileManager_Utils.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/3/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        static let systemFiles   = [".DS_Store"]

        static let imageFolder   = "_images"
        static let productFolder = "_products"
    }

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    enum SupportedSandboxDirs {

        case docs, cache, image, products
    }

    enum SupportedSandboxFiles: String {

        case images     = "_images.plist"
        case products   = "_products.plist"
    }

    enum SupportedImageTypes: String {

        case jpg, jpeg, png

        static let jpgs = [SupportedImageTypes.jpg, jpeg]
        static let pngs = [SupportedImageTypes.png]
        static let all  = [SupportedImageTypes.jpg, .jpeg, .png]

        static func isSupportedImageType(ext: String) -> Bool {

            return isImageType(types: all, fileExtension: ext)
        }

        static func isJPG(ext: String) -> Bool {

            return isImageType(types: jpgs, fileExtension: ext)
        }

        static func isPNG(ext: String) -> Bool {

            return isImageType(types: pngs, fileExtension: ext)
        }

        private static func isImageType(types: [SupportedImageTypes], fileExtension: String) -> Bool {

            let ext = fileExtension.lowercased()
            for testType in types {

                if testType.rawValue == ext {

                    return true
                }
            }

            return false
        }
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var cacheDir: String? {

        return url(for: .cachesDirectory)?.path
    }

    var docsDir: String? {

        return url(for: .documentDirectory)?.path
    }

    var imagesDir: String? {

        var dir = cacheDir
        if let imageDir = dir {

            // sub-folder for organization
            let newDir = "\(imageDir)/\(Constants.imageFolder)"

            // need to make sure it exists
            createDirIfNoExist(filepath: newDir)
            dir = newDir
        }

        // default
        return dir
    }

    var productsDir: String? {

        var dir = cacheDir
        if let productDir = dir {

            // sub-folder for organization
            let newDir = "\(productDir)/\(Constants.productFolder)"

            // need to make sure it exists
            createDirIfNoExist(filepath: newDir)
            dir = newDir
        }

        // default
        return dir
    }

    ///////////////////////////////////////////////////////////
    // API - image item level
    ///////////////////////////////////////////////////////////

    func loadImage(filename: String) -> UIImage? {

        // construct sandbox file path
        guard let filepath = fullPath(for: filename, in: .image) else { return nil }

        // load
        let image = UIImage(contentsOfFile: filepath)
        return image
    }
    
    func saveImage(filename: String, image: UIImage) -> Bool {

        // construct sandbox file path
        guard let filepath = fullPath(for: filename, in: .image) else { return false }

        // must be image type we support
        let ext = filename.ext
        guard SupportedImageTypes.isSupportedImageType(ext: ext) else { return false }

        // get data
        var data: Data?
        if SupportedImageTypes.isJPG(ext: ext) {

            data = UIImageJPEGRepresentation(image, 1.0)
        }
        else if SupportedImageTypes.isPNG(ext: ext) {

            data = UIImagePNGRepresentation(image)
        }

        // must have data to save
        guard let imageData = data else { return false }

        // save
        let success = self.createFile(atPath: filepath, contents: imageData, attributes: nil)
        return success
    }

    func deleteImage(filename: String) -> Bool {

        return deleteFileItem(filename: filename, in: .image)
    }

    ///////////////////////////////////////////////////////////
    // API - product archive item level
    ///////////////////////////////////////////////////////////

    func loadProductsFetch(filename: String) -> ProductsFetch? {

        // construct sandbox file path
        guard let filepath = fullPath(for: filename, in: .products) else { return nil }

        // load
        let productsFetch = ProductsFetch.create(contentsOfFile: filepath)
        return productsFetch
    }

    func saveProductsFetch(filename: String, productsFetch: ProductsFetch) -> Bool {

        // construct sandbox file path
        guard let filepath = fullPath(for: filename, in: .products) else { return false }

        // save
        return productsFetch.save(toFile: filepath)
    }

    func deleteProductsFetch(filename: String) -> Bool {

        return deleteFileItem(filename: filename, in: .products)
    }

    ///////////////////////////////////////////////////////////
    // API - file level
    ///////////////////////////////////////////////////////////

    func writeFile(fileType: SupportedSandboxFiles, dict: [String : Any]) -> Bool {

        // construct sandbox file path
        guard let filepath = fullPath(for: fileType.rawValue, in: .cache) else { return false }

        // write out
        let success = (dict as NSDictionary).write(toFile: filepath, atomically: true)
        return success
    }

    func readFile(fileType: SupportedSandboxFiles) -> [String : Any] {

        // construct sandbox file path
        guard let filepath = fullPath(for: fileType.rawValue, in: .cache) else { return [:] }

        // read the dict
        if let nsDict = NSDictionary(contentsOfFile: filepath) {

            if let dict = nsDict as? [String : Any] {

                return dict
            }
        }

//        // read
//        do {
//
//            // file based url
//            if let url = URL(string: filepath) {
//
//                // grab dict data
//                let data = try Data.init(contentsOf: url)
//
//                // serialize
//                let result = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
//
//                // cast into desired output
//                if let dict = result as? [String : Any] {
//
//                    return dict
//                }
//            }
//        }
//        catch {
//
//            print(error)
//        }

        return [:]
    }

    ///////////////////////////////////////////////////////////
    // helpers
    ///////////////////////////////////////////////////////////

    private func deleteFileItem(filename: String, in dir: SupportedSandboxDirs) -> Bool {

        // construct sandbox file path
        guard let filepath = fullPath(for: filename, in: dir) else { return false }

        // delete
        let success = deleteFile(atPath: filepath)
        return success
    }

    private func fullPath(for filename: String, in dir: SupportedSandboxDirs) -> String? {

        switch dir {

            case .docs:
                guard let docsDir = docsDir else { return nil }
                return docsDir.stringByAppendingPathComponent(path: filename)

            case .cache:
                guard let cacheDir = cacheDir else { return nil }
                return cacheDir.stringByAppendingPathComponent(path: filename)

            case .image:
                guard let imagesDir = imagesDir else { return nil }
                return imagesDir.stringByAppendingPathComponent(path: filename)

            case .products:
                guard let productsDir = productsDir else { return nil }
                return productsDir.stringByAppendingPathComponent(path: filename)
        }
    }

    private func deleteFile(atPath: String) -> Bool {

        // no data, clear
        if self.fileExists(atPath: atPath) {

            if self.isDeletableFile(atPath: atPath) {

                // try to delete
                do {

                    try self.removeItem(atPath: atPath)

                    // successful
                    return true
                }
                catch {

                    // error
                    print(error.localizedDescription)
                    return false
                }
            }
            else {

                // file unable to delete
                return false
            }
        }

        // file doesn't exist
        return true
    }

    private func createDir(atPath: String) -> Bool {

        // check for existance
        guard !self.fileExists(atPath: atPath) else { return true }

        // create
        do {

            try self.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch {

            print("error:", error.localizedDescription)
            return false
        }
    }

    private func cleanDir(atPath: String) {

        do {

            let files = try self.contentsOfDirectory(atPath: atPath)

            // spin through each file and delete
            for file in files {

                // skip system files
                if Constants.systemFiles.contains(file) {

                    continue
                }

                // delete
                if let fullPath = docsDir?.stringByAppendingPathComponent(path: file) {

                    try self.removeItem(atPath: fullPath)
                }
            }
        }
        catch {

            print("#function", error.localizedDescription)
        }
    }

    private func deleteDir(atPath: String) -> Bool {

        // todo
        return true
    }

    private func url(for directory: FileManager.SearchPathDirectory) -> URL? {

        // typical use: docs dir, cache dir, etc
        let fm = FileManager.default
        guard let searchURL = fm.urls(for: directory, in: .userDomainMask).first else { return nil }
//        print("sandbox url: ", searchURL.path)
        return searchURL
    }

    private func createDirIfNoExist(filepath: String) {

        if !self.fileExists(atPath: filepath) {

            // create custom subdir w/ intermediary dirs
            if let _ = try? self.createDirectory(atPath: filepath, withIntermediateDirectories: true, attributes: nil) {

                print("created new folder store: \(filepath)")
            }
        }
    }
}

