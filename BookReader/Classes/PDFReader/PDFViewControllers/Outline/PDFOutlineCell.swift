//
//  PDFOutlineCell.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class PDFOutlineCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pageNumberLabel: UILabel!
    @IBOutlet private weak var indentationConstraint: NSLayoutConstraint!

    // MARK: - Variables
    var label: String? = nil {
        didSet {
            titleLabel.text = label
        }
    }
    var pageLabel: String? = nil {
        didSet {
            pageNumberLabel.text = pageLabel
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.textColor = .gray
        pageNumberLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }

    override func updateConstraints() {
        super.updateConstraints()
        indentationConstraint.constant = CGFloat(15 + 10 * indentationLevel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.font =
            indentationLevel == 0 ? .preferredFont(forTextStyle: .headline) : .preferredFont(forTextStyle: .body)
        separatorInset = UIEdgeInsets(top: 0,
                                      left: safeAreaInsets.right + indentationConstraint.constant,
                                      bottom: 0,
                                      right: 0)
    }
}
