//
//  PDFThumbnailGridCell.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class PDFThumbnailGridCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var pageNumberLabel: UILabel!

    // MARK: - Variables
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.8 : 1
        }
    }
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = String(pageNumber)
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.isHidden = true
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
}
