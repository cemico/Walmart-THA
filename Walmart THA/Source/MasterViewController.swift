//
//  MasterViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    private struct Constants {

        // don't wait until hit bottom before fetching more,
        // instead kick off the lazy loading operation as
        // we begin to sneak up on the last cell ... here
        // we configure the number of cells before the
        // last to start the next data fetch
        static let preCellThresholdToFetchMore = 5
    }

    var detailViewController: DetailViewController? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton

        // extract details controller
        if let split = splitViewController {

            let controllers = split.viewControllers
            detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        // clear previous selection
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc func insertNewObject(_ sender: Any) {

        fetchMoreResults()
    }

    func scrollUpAfterFetch() {

        // pop scroll to show more data
        // note: needs some tlc, minor item, easy to remove, revisit when major items are complete
        let visibleCellIndexPaths = self.tableView.indexPathsForVisibleRows
        guard let lastCellIndexPath = visibleCellIndexPaths?.last else { return }
        print("last cell: \(lastCellIndexPath.row)")

        guard lastCellIndexPath.row < ProductDataController.shared.products.count - 1 else { return }
        let scrollIndexPath = IndexPath.init(row: lastCellIndexPath.row + 1, section: 0)

        // mild spring
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.1, options: [.curveEaseOut], animations: {

            // auto-scroll to new data row
            self.tableView.scrollToRow(at: scrollIndexPath, at: .none, animated: false)

        }, completion: { success in

        })
    }

    func prefetchCheckFrom(indexPath: IndexPath) {

        // see if getting close to end of data, adjust for zero-base
        let numberOfProducts = max(0, ProductDataController.shared.products.count - 1)
        let numberOfRowsBeforeEnd = numberOfProducts - indexPath.row
        let shouldFetchMore = (numberOfRowsBeforeEnd <= Constants.preCellThresholdToFetchMore)

        if shouldFetchMore {

            // initiate early fetch
            print("fetching request from row: \(indexPath.row) of \(numberOfProducts) products")
            fetchMoreResults()
        }
    }

    func fetchMoreResults() {

        // check if more results available to fetch
        guard ProductDataController.shared.isMoreDataAvailableToFetch else { return }

        // visual indicator
        self.navigationItem.title = "Products (loading...)"

        // get first batch
        DispatchQueue.global().async {

            // animate first results set
            let isFirstFetch = (ProductDataController.shared.products.count == 0)

            // fetch more objects
            ProductDataController.shared.getPartialProductList { (error: Error?, products: [ProductItem]) in

                if error == nil, !products.isEmpty {

                    DispatchQueue.main.async { [weak self] in

                        guard let strongSelf = self else { return }

                        if isFirstFetch {

                            // cool factor, how about animating in first set of items
                            strongSelf.tableView.reloadData(with: .fromBottom)
                        }
                        else {

//                            // animate the additions
//                            let beginningIndex = max(0, ProductDataController.shared.products.count - products.count - 1)
//                            strongSelf.tableView.beginUpdates()
//                            for (index, _) in products.enumerated() {
//
//                                let indexPath = IndexPath.init(row: index + beginningIndex, section: 0)
//                                strongSelf.tableView.insertRows(at: [indexPath], with: .left)
//                            }
//                            strongSelf.tableView.endUpdates()

                            // new rows are not visible, no need to animate
                            strongSelf.tableView.reloadData()

//                            // playing around with feedback animation
//                            strongSelf.scrollUpAfterFetch()
                        }

                        // visual feedback
                        strongSelf.navigationItem.title = "Products (\(ProductDataController.shared.products.count))"

                        // haptic feedback
                        SoundManager.shared.hapticFeedback(type: .notification(.success))
                    }
                }
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // destination segue id
        if segue.identifier == "showDetail" {

            // need selected row
            if let indexPath = tableView.indexPathForSelectedRow {

                // model data
                let productItem = ProductDataController.shared.products[indexPath.row]

                // destination controller
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                // set model data
                controller.productItem = productItem

                // set nav buttons for when master pane is showing and not
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return ProductDataController.shared.products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ProductItemTableViewCell.className, for: indexPath)

        if let cell = cell as? ProductItemTableViewCell {

            // grab model for this row
            let productItem = ProductDataController.shared.products[indexPath.row]

            // setup
            cell.configure(row: indexPath.row, model: productItem)
        }

        // check for pre-fetch
        prefetchCheckFrom(indexPath: indexPath)

        return cell
    }
}

///////////////////////////////////////////////////////////
// MARK: - Table Cells
///////////////////////////////////////////////////////////

class ProductItemTableViewCell: UITableViewCell {

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var ratingStarsView: RatingStarsView!
    @IBOutlet weak var numberRatingsLabel: UILabel!

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    private var productItem: ProductItem? = nil {

        didSet {

            // update outlets
            if let productItem = productItem {

                productName.text = productItem.name.html2String.withoutUnicodeChars
                productPrice.text = productItem.price
                ratingStarsView.rankingFill = CGFloat(productItem.reviewRating)
                numberRatingsLabel.text = "(\(productItem.reviewCount))"

                // load image
                let currentRow = productImageView.tag
                AppDataController.shared.loadImage(url: productItem.imageUrl, completionHandler: { [weak self] image in

                    DispatchQueue.main.async {

                        if let strongSelf = self, strongSelf.productImageView.tag == currentRow {

                            strongSelf.productImageView.image = image
                        }
                        else {

                            print("Image update skipped due to row reuse")
                        }
                    }
                })
            }
        }
    }

    ///////////////////////////////////////////////////////////
    // overrides
    ///////////////////////////////////////////////////////////

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // get ready for reuse
        productItem = nil
    }

    ///////////////////////////////////////////////////////////
    // actions
    ///////////////////////////////////////////////////////////

    func configure(row: Int, model: ProductItem) {

        // any one-time configuration outside of data model being set
        productImageView.tag = row

        // save model
        self.productItem = model
    }
}
