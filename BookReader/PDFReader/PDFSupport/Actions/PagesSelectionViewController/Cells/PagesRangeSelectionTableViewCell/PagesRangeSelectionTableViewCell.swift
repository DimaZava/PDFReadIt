//
//  PagesRangeSelectionTableViewCell.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

protocol PagesRangeSelectionTableViewCellDelegate: AnyObject {
    func didUpdate(range: ClosedRange<Int>)
}

class PagesRangeSelectionTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var rangePickerView: UIPickerView!

    // MARK: - Variables
    weak var delegate: PagesRangeSelectionTableViewCellDelegate?
    var item: PageViewModel.PageSelectionItem?
    var documentRange: ClosedRange<Int>?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        rangePickerView.delegate = self
        rangePickerView.dataSource = self
    }

    func configure(for item: PageViewModel.PageSelectionItem, documentRange: ClosedRange<Int>) {
        self.item = item
        self.documentRange = documentRange
        guard case .range(let range) = item else { return }
        rangePickerView.reloadAllComponents()
        rangePickerView.selectRow(range.lowerBound - 1, inComponent: 0, animated: false)
        rangePickerView.selectRow(range.upperBound - 1, inComponent: 1, animated: false)
    }
}

extension PagesRangeSelectionTableViewCell: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard case .range = item,
            pickerView.selectedRow(inComponent: 0) <= pickerView.selectedRow(inComponent: 1) else { return }

        delegate?.didUpdate(range: pickerView.selectedRow(inComponent: 0) + 1...pickerView.selectedRow(inComponent: 1) + 1)
    }
}

extension PagesRangeSelectionTableViewCell: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let documentRange = documentRange else { return 0 }
        return documentRange.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
}
