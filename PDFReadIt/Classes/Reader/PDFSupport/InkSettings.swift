//
//  InkSettings.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettings {

    static let sharedInstance = InkSettings()

    // MARK - Variables
    var strokeColor: UIColor
    var fillColor: UIColor?
    var opacity: Float
    var thickness: Float

    // MARK: - Lifecycle
    private init() {
        strokeColor = .blue
        fillColor = nil
        opacity = 1
        thickness = 10
    }
}
