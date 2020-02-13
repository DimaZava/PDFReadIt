//
//  PagesSelectionTableViewCell.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class PagesSelectionTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    func configure(for item: PageViewModel.PageSelectionItem, in viewModel: PageViewModel) {
        titleLabel.text = item.title
        accessoryType = viewModel.selectedItem == item ? .checkmark : .none
    }
}
