//
//  MasterViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

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

        let rect = CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 1)
        let label = UILabel.init(frame: rect)
        label.backgroundColor = UIColor.blue
        self.tableView.tableFooterView = label
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
                            strongSelf.scrollUpAfterFetch()
                        }

                        strongSelf.navigationItem.title = "Products (\(ProductDataController.shared.products.count))"
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
                controller.detailItem = productItem

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

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // get model data
        let productItem = ProductDataController.shared.products[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row + 1): " + productItem.name
        return cell
    }
}

