//
//  InkSettingsColorPickerViewController.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

protocol InkSettingsStrokeColorViewControllerDelegate: AnyObject {
    func didSelect(color: UIColor, for mode: InkSettingsColorPickerViewController.Mode)
}

class InkSettingsColorPickerViewController: UIViewController {

    enum Mode {
        case strokeColor
        case fillColor
    }

    // MARK: - Variables
    weak var delegate: InkSettingsStrokeColorViewControllerDelegate?
    var colorPicker: ChromaColorPicker!
    let currentMode: Mode

    // MARK: - Lifecycle
    init(with mode: Mode) {
        currentMode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Color"
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        colorPicker = ChromaColorPicker()
        colorPicker.delegate = self
        colorPicker.padding = 10
        colorPicker.stroke = 3

        switch currentMode {
        case .strokeColor:
            colorPicker.currentColor = InkSettings.sharedInstance.strokeColor
        case .fillColor:
            break //colorPicker.currentAngle = colorPicker.angleForColor(InkSettings.sharedInstance.fillColor)
        }

        view.addSubview(colorPicker)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard colorPicker.frame.width != view.bounds.width * 0.8 else { return }
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor,
                                             multiplier: 1).isActive = true
        colorPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        colorPicker.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.8).isActive = true
        colorPicker.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.8).isActive = true

        navigationController?.preferredContentSize = CGSize(width: 0, height: view.bounds.width * 0.8)
    }
}

extension InkSettingsColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        delegate?.didSelect(color: color, for: currentMode)
    }
}
