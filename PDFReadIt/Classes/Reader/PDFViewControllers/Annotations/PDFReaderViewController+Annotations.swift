//
//  PDFReaderViewController+Annotations.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension PDFReaderViewController {

    func enableAnnotationMode() {
        showAnnotationControls()
        addDrawingGestureRecognizerToPDFView()
    }

    func disableAnnotationMode() {
        resumeDefaultState()
        removeDrawingGestureRecognizerFromPDFView()
    }
}

private extension PDFReaderViewController {

    func showAnnotationControls() {
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTouchUpInside(_:)))
        ]

        let rightBarButtonItems = [
            UIBarButtonItem(title: "Ink", style: .plain, target: self, action: #selector(selectInkOptionsButtonTouchUpInside(_:))),
            UIBarButtonItem(title: "Text", style: .plain, target: self, action: #selector(setTextButtonTouchUpInside(_:)))
        ]
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    @objc
    func selectInkOptionsButtonTouchUpInside(_ sender: UIBarButtonItem) {
        let inkSettingsViewController = InkSettingsViewController(nibName: String(describing: InkSettingsViewController.self), bundle: nil)
        inkSettingsViewController.modalPresentationStyle = .popover
        inkSettingsViewController.popoverPresentationController?.barButtonItem = sender
        inkSettingsViewController.popoverPresentationController?.permittedArrowDirections = .up
        inkSettingsViewController.popoverPresentationController?.delegate = self

        let navigationController = UINavigationController(rootViewController: inkSettingsViewController)
        present(navigationController, animated: true)
    }

    @objc
    func setTextButtonTouchUpInside(_ sender: Any) {
    }

    @objc
    func doneButtonTouchUpInside(_ sender: Any) {
        disableAnnotationMode()
    }
}
