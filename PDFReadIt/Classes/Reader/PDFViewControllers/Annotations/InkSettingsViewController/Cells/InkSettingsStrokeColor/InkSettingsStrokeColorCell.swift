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
    @IBOutlet weak var strokeColorImagePreview: UIView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        strokeColorImagePreview.layer.cornerRadius = strokeColorImagePreview.frame.width / 2
        strokeColorImagePreview.layer.borderColor = UIColor.lightGray.cgColor
        strokeColorImagePreview.layer.masksToBounds = true
    }

    func configure(with settings: InkSettings) {
        strokeColorImagePreview.backgroundColor = settings.strokeColor
    }
}
