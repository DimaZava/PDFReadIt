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

        pdfNextPageChangeSwipeGestureRecognizer?.isEnabled = false
        pdfPrevPageChangeSwipeGestureRecognizer?.isEnabled = false
        pdfViewGestureRecognizer.isEnabled = false
        barHideOnTapGestureRecognizer.isEnabled = false
    }

    func disableAnnotationMode() {
        resumeDefaultState()
        removeDrawingGestureRecognizerFromPDFView()

        pdfNextPageChangeSwipeGestureRecognizer?.isEnabled = true
        pdfPrevPageChangeSwipeGestureRecognizer?.isEnabled = true
        pdfViewGestureRecognizer.isEnabled = true
        barHideOnTapGestureRecognizer.isEnabled = true
    }
}

private extension PDFReaderViewController {

    func showAnnotationControls() {

        hideBars(needsToHideNavigationBar: false)

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
        let navigationController = UINavigationController(rootViewController: inkSettingsViewController)
        presentPopover(navigationController, barButtonItem: sender)
    }

    @objc
    func setTextButtonTouchUpInside(_ sender: Any) {
    }

    @objc
    func doneButtonTouchUpInside(_ sender: Any) {
        disableAnnotationMode()
    }
}
