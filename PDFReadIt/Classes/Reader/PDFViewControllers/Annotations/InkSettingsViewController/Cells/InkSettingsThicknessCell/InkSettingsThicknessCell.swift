//
//  InkSettingsThicknessCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

protocol InkSettingsThicknessCellDelegate: AnyObject {
    func didUpdate(thickness value: Float)
}

class InkSettingsThicknessCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var thicknessSlider: UISlider!
    @IBOutlet private weak var thicknessLabel: UILabel!

    // MARK: - Variables
    weak var delegate: InkSettingsThicknessCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        thicknessSlider.addTarget(self, action: #selector(didChangeThicknessSliderValue(_:)), for: .valueChanged)
    }

    func configure(with settings: InkSettings) {
        thicknessSlider.setValue(settings.thickness / 20, animated: false)
        thicknessLabel.text = "\(Int(settings.thickness)) pt"
    }

    @objc
    func didChangeThicknessSliderValue(_ slider: UISlider) {
        InkSettings.sharedInstance.thickness = slider.value * 20
        thicknessLabel.text = "\(Int(InkSettings.sharedInstance.thickness)) pt"
        delegate?.didUpdate(thickness: InkSettings.sharedInstance.thickness)
    }
}
