//
//  InkSettingsFillColorCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettingsFillColorCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var fillColorImagePreview: UIView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        fillColorImagePreview.layer.cornerRadius = fillColorImagePreview.frame.width / 2
        fillColorImagePreview.layer.borderColor = UIColor.lightGray.cgColor
        fillColorImagePreview.layer.masksToBounds = true
    }

    func configure(with settings: InkSettings) {
        fillColorImagePreview.backgroundColor = settings.fillColor
    }
}
