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
        setDefaultUIState()
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

        let bundle = Bundle(for: Self.self)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "PDFReaderInk", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(selectInkOptionsButtonTouchUpInside(_:)))
        ]
    }

    @objc
    func selectInkOptionsButtonTouchUpInside(_ sender: UIBarButtonItem) {
        let nibName = String(describing: InkSettingsViewController.self)
        let bundle = Bundle(for: Self.self)
        let inkSettingsViewController = InkSettingsViewController(nibName: nibName, bundle: bundle)
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
