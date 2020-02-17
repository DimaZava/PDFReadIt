//
//  InkSettingsToolCollectionCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 17.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettingsToolCollectionCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var toolIconImageView: UIImageView!

    // MARK: - Lifecycle
    func configure(_ tool: InkSettings.DrawingTool) {
        toolIconImageView.image = tool.icon
        toolIconImageView.tintColor = InkSettings.sharedInstance.tool == tool ? .systemBlue : .lightGray
    }
}
