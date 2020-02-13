//
//  PageActionTableViewCell.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class PageActionTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
    }

    // MARK: - Lifecycle
    func configure(with item: PageViewModel.PageSelectionItem) {
        titleLabel.text = item.title
    }
}
