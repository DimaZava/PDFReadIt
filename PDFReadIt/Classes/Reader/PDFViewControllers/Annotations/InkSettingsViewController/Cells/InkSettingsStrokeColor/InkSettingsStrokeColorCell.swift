//
//  InkSettingsStrokeColorCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettingsStrokeColorCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var strokeColorImagePreview: UIView!
    @IBOutlet private weak var disableIndicatorView: UIView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        strokeColorImagePreview.layer.cornerRadius = strokeColorImagePreview.frame.width / 2
        strokeColorImagePreview.layer.borderColor = UIColor.lightGray.cgColor
        strokeColorImagePreview.layer.masksToBounds = true
    }

    func configure(with settings: InkSettings) {
        if case .eraser = settings.tool {
            disableIndicatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            isUserInteractionEnabled = false
            return
        }

        isUserInteractionEnabled = true
        disableIndicatorView.backgroundColor = .clear
        strokeColorImagePreview.backgroundColor = settings.strokeColor
    }
}
