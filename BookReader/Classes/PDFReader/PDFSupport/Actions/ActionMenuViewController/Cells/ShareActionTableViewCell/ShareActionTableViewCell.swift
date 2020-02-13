//
//  ShareActionTableViewCell.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class ShareActionTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    func configure(with item: ShareViewModel.ShareItem) {
        titleLabel.text = item.title
    }
}
