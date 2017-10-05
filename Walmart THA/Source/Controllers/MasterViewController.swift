//
//  MasterViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        // don't wait until hit bottom before fetching more,
        // instead kick off the lazy loading operation as
        // we begin to sneak up on the last cell ... here
        // we configure the number of cells before the
        // last to start the next data fetch
        static let preCellThresholdToFetchMore = 5

        static let detailSegue = "showDetail"
    }

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // details pane
    private var detailViewController: DetailViewController? = nil

    // optimize master detail coordination
    private var collapseDetailViewController = true

    // loading indicator
    private var isLoadingData = false

    // initial animation flag
    private var isCellHidden = true

    // search bar filtered data
    private var filteredData: [ProductItem] = []

    // setup search search controller
    private lazy var searchController: UISearchController = {

        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        sc.definesPresentationContext = true
        return sc
    }()

    ///////////////////////////////////////////////////////////
    // overrides
    ///////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        // grab inital data
        fetchMoreResults()

        // extract details controller
        if let split = splitViewController {

            let controllers = split.viewControllers
            detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
        }

        // setup search bar
        // note: few boundary conditions needs to be cleaned up
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {

//        // track display mode changes
//        splitViewController?.delegate = self

        // clear previous selection
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func setDetailOnEntry() {

        let isPadAndPlusLandscape = UIScreen.main.traitCollection.horizontalSizeClass == .regular
        let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
        let setDefaultSelectedRow = (isPad || isPadAndPlusLandscape)

        // handle iPhone + models and iPad on entry
        if setDefaultSelectedRow, let dvc = detailViewController {

            if filteredData.count > 0, dvc.productItem == nil {

                var indexPath = IndexPath.init(row: 0, section: 0)

                if let firstVisible = tableView.indexPathsForVisibleRows?.first {

                    indexPath = firstVisible

                    // first cell is obscured under the nav bar, get 2nd one if exists
                    if tableView.contentOffset.y > 0,
                        let visiblePaths = tableView.indexPathsForVisibleRows,
                        visiblePaths.count > 1 {

                        indexPath = visiblePaths[1]
                    }
                }

                // need selected row to determine model for segue
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.performSegue(withIdentifier: Constants.detailSegue, sender: nil)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in

        }) { context in

            self.setDetailOnEntry()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // keep the loading view in sync
//        updateLoadingPosition()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // destination segue id
        if segue.identifier == Constants.detailSegue {

            // need selected row
            if let indexPath = tableView.indexPathForSelectedRow {

                // model data
                let productItem = filteredData[indexPath.row]

                // destination controller
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                // set model data
                controller.productItem = productItem

                // set nav buttons for when master pane is showing and not
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }

            if searchController.isActive {

                // auto-close search if open
                searchController.isActive = false
            }
        }
    }

    ///////////////////////////////////////////////////////////
    // helpers - loading view
    ///////////////////////////////////////////////////////////

    func updateLoadingPosition() {

        let tableRect = self.tableView.frame
        var loadingRect = loadingView.frame

        loadingRect.origin.x = 0
        loadingRect.size.width = tableRect.size.width

        // keep the loading view in sync
        if isLoadingData {

            // shown at the bottom of the table
            loadingRect.origin.y = tableRect.maxY - loadingRect.size.height
        }
        else {

            // not shown, resides just below the table
            loadingRect.origin.y = tableRect.maxY
        }

        if !loadingView.frame.equalTo(loadingRect) {

            loadingView.frame = loadingRect
            print(loadingRect)
        }
    }

    func showLoading(show: Bool) {

        // sanity check if already doing the action
        guard isLoadingData != show else { return }

        isLoadingData = show
        view.bringSubview(toFront: loadingView)

        // spinner control
        if show {

            loadingSpinner.startAnimating()
        }
        else {

            loadingSpinner.stopAnimating()
        }

        UIView.animate(withDuration: 0.5, animations: {

            // animate into position
            self.updateLoadingPosition()

        }) { success in

        }
    }

    ///////////////////////////////////////////////////////////
    // helpers - search bar
    ///////////////////////////////////////////////////////////

    var isSearchBarEmpty: Bool {

        if let text = searchController.searchBar.text, text.count > 0 {

            return false
        }

        return true
    }

    func updateSearchResults(for searchController: UISearchController) {

        guard !isSearchBarEmpty else {

            // reset
            filteredData = ProductDataController.shared.products
            self.tableView.reloadData()
            return
        }

        // get search text
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }

        // apply filter
//        let namePredicate = NSPredicate(format: "name like %@", searchText)
        filteredData = ProductDataController.shared.products.filter({ $0.name.lowercased().contains(searchText) })

        // refresh
        self.tableView.reloadData()
    }

    ///////////////////////////////////////////////////////////
    // helpers - data load
    ///////////////////////////////////////////////////////////

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
        self.navigationItem.title = "Loading More..."

        // visual loading indicator
//        showLoading(show: true)

        // get first batch, higher priority background queue
        DispatchQueue.global(qos: .userInitiated).async {

            // animate first results set
            let isFirstFetch = (ProductDataController.shared.products.count == 0)

            // fetch more objects
            ProductDataController.shared.getPartialProductList { (error: Error?, products: [ProductItem]) in

                DispatchQueue.main.async { [weak self] in

                    guard let strongSelf = self else { return }

                    // done loading
//                    strongSelf.showLoading(show: false)

                    if error == nil, !products.isEmpty {

                        // update data
                        strongSelf.filteredData = ProductDataController.shared.products

                        if isFirstFetch {

                            // handle details initial state
                            strongSelf.setDetailOnEntry()

//                            // set initial details model in case of landscape
//                            strongSelf.detailViewController?.productItem = strongSelf.filteredData.first

                            // cool factor, how about animating in first set of items
                            strongSelf.tableView.reloadData(with: .fromBottom) {

                                // to prevent flicker of visible cells before animation, hide them until
                                // until animation moves them offscreen in prep to animate back in place
                                strongSelf.isCellHidden = false
                            }
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
                    }

                    // visual feedback
                    strongSelf.navigationItem.title = "Products (\(ProductDataController.shared.products.count))"

                    // haptic feedback
                    SoundManager.shared.hapticFeedback(type: .notification(.success))
                }
            }
        }
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
}

extension MasterViewController: UISplitViewControllerDelegate {

    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {

        // mode changed - update dynamic content
        detailViewController?.displayModeUpdated()
    }

    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {

        return collapseDetailViewController
    }
}

extension MasterViewController {

    ///////////////////////////////////////////////////////////
    // MARK: - Table View
    ///////////////////////////////////////////////////////////

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ProductItemTableViewCell.className, for: indexPath)

        cell.isHidden = isCellHidden
        if let cell = cell as? ProductItemTableViewCell {

            // grab model for this row
            let productItem = filteredData[indexPath.row]

            // setup
            cell.configure(row: indexPath.row, model: productItem)
        }

        // check for pre-fetch
        prefetchCheckFrom(indexPath: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        collapseDetailViewController = false
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
