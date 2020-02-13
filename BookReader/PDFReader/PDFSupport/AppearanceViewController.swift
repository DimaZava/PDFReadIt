//
//  AppearanceViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class AppearanceViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var brightnessSlider: UISlider!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        brightnessSlider.value = Float(UIScreen.main.brightness)
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    // MARK: - Actions
    @objc
    func sliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(brightnessSlider.value)
    }
}
