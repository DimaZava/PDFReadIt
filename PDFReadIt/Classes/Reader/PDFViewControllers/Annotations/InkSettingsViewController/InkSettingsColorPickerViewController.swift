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

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

//        let pickerSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.width * 0.8)
//        let pickerOrigin = CGPoint(x: view.bounds.midX - pickerSize.width / 2,
//                                   y: view.bounds.midY - pickerSize.height / 2)

        colorPicker = ChromaColorPicker(frame: view.frame)
        colorPicker.delegate = self

        colorPicker.padding = 10
        colorPicker.stroke = 3
        colorPicker.currentAngle = Float.pi
        colorPicker.supportsShadesOfGray = true
        colorPicker.hexLabel.textColor = UIColor.white
        colorPicker.fillToSuperview()

        view.addSubview(colorPicker)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.preferredContentSize = colorPicker.intrinsicContentSize
    }
}

extension InkSettingsColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        delegate?.didSelect(color: color, for: currentMode)
    }
}
