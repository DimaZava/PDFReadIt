//
//  InkSettingsOpacityCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

protocol InkSettingsOpacityCellDelegate: AnyObject {
    func didUpdate(opacity value: Float)
}

class InkSettingsOpacityCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var opacitySlider: UISlider!
    @IBOutlet private weak var opacityLabel: UILabel!
    @IBOutlet private weak var disableIndicatorView: UIView!

    // MARK: - Variables
    weak var delegate: InkSettingsOpacityCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        opacitySlider.addTarget(self, action: #selector(didChangeOpacitySliderValue(_:)), for: .valueChanged)
    }

    func configure(with settings: InkSettings) {
        if case .eraser = settings.tool {
            disableIndicatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            disableIndicatorView.isHidden = false
            isUserInteractionEnabled = false
            return
        }

        isUserInteractionEnabled = true
        disableIndicatorView.isHidden = true
        disableIndicatorView.backgroundColor = .clear
        opacitySlider.setValue(settings.opacity, animated: false)
        opacityLabel.text = "\(Int(settings.opacity * 100))%"
    }

    @objc
    func didChangeOpacitySliderValue(_ slider: UISlider) {
        InkSettings.sharedInstance.opacity = slider.value
        opacityLabel.text = "\(Int(InkSettings.sharedInstance.opacity * 100))%"
        delegate?.didUpdate(opacity: InkSettings.sharedInstance.opacity)
    }
}
