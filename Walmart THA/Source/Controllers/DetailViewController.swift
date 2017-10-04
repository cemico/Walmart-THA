//
//  DetailViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/1/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        static let longDescriptionSegue = "ShowLongDescription"
    }

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet weak var tableView: UITableView!

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    var productItem: ProductItem? = nil

    ///////////////////////////////////////////////////////////
    // overrides
    ///////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        // remove dead lines in tableview
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)

        // update display
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let productItem = self.productItem else { return }
        guard segue.identifier == Constants.longDescriptionSegue else { return }
        guard let vc = segue.destination as? LongDescriptionViewController else { return }

        // model up vc
        vc.productItem = productItem
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {

    // note: opted for dynamic rows over static to more easily add/change in future
    private enum TableHeight: Int {

        case summary = 360
        case details = 80
    }

    private enum TableRow: Int {

        case summary = 0
        case details = 1

        static let all = [TableRow.summary, .details]

        func toHeight() -> TableHeight {

            switch self {

                case .summary:
                    return TableHeight.summary

                case .details:
                    return TableHeight.details
            }
        }

        static func toEnum(from row: Int) -> TableRow {

            switch row {

                case TableRow.summary.rawValue:
                    return .summary

                default:
                    return .details
            }
        }
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let height = TableRow.toEnum(from: indexPath.row).toHeight()
        return CGFloat(height.rawValue)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return TableRow.all.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // summary
        if TableRow.toEnum(from: indexPath.row) == .summary {

            let cell = tableView.dequeueReusableCell(withIdentifier: FullDetailsTableViewCell.className, for: indexPath)

            if let cell = cell as? FullDetailsTableViewCell, let productItem = productItem {

                // setup
                cell.configure(row: indexPath.row, model: productItem)
            }

            return cell
        }

        // details
        let cell = tableView.dequeueReusableCell(withIdentifier: LongDescriptionTableViewCell.className, for: indexPath)

        if let cell = cell as? LongDescriptionTableViewCell, let productItem = productItem {

            // setup
            cell.configure(row: indexPath.row, model: productItem)
        }

        return cell
    }
}

///////////////////////////////////////////////////////////
// MARK: - Table Cells
///////////////////////////////////////////////////////////

class FullDetailsTableViewCell: UITableViewCell {

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var ratingStarsView: RatingStarsView!
    @IBOutlet weak var numberRatingsLabel: UILabel!
    @IBOutlet weak var productNameHeightConstraint: NSLayoutConstraint!

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

                // allow for up to 2 lines of text, shifting all text below
//                let height = productName.attributedText!.height(withConstrainedWidth: productName.frame.size.width)
                let height = productName.text!.height(withConstrainedWidth: productName.frame.size.width, font: productName.font)
                productNameHeightConstraint.constant = min(2 * productNameHeightConstraint.constant, height + 2)
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

class LongDescriptionTableViewCell: UITableViewCell {
    
    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsPreviewLabel: UILabel!

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    private var productItem: ProductItem? = nil {

        didSet {

            // update outlets
            if let productItem = productItem {

                titleLabel.text = productItem.name.html2String
                detailsPreviewLabel.attributedText = productItem.longDescription.html2AttributedString
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

        productItem = nil
    }

    ///////////////////////////////////////////////////////////
    // actions
    ///////////////////////////////////////////////////////////

    func configure(row: Int, model: ProductItem) {

        // any one-time configuration outside of data model being set

        // save model
        self.productItem = model
    }
}
