//
//  PDFReaderViewController+Delegates.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 18.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import MessageUI
import PDFKit
import UIKit

// MARK: - UIPopoverPresentationControllerDelegate
extension PDFReaderViewController: UIPopoverPresentationControllerDelegate {
    open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - ActionMenuViewControllerDelegate
extension PDFReaderViewController: ActionMenuViewControllerDelegate {
}

// MARK: - UIGestureRecognizerDelegate
extension PDFReaderViewController: UIGestureRecognizerDelegate {

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == barHideOnTapGestureRecognizer {
            return true
        }
        return false
    }
}

// MARK: - SearchViewControllerDelegate
extension PDFReaderViewController: SearchViewControllerDelegate {

    func searchViewController(_ searchViewController: PDFSearchViewController,
                              didSelectSearchResult selection: PDFSelection) {
        selectAndOpen(selection)
        showBars()
    }
}

// MARK: - OutlineViewControllerDelegate
extension PDFReaderViewController: OutlineViewControllerDelegate {

    func outlineViewController(_ outlineViewController: PDFOutlineViewController,
                               didSelectOutlineAt destination: PDFDestination) {
        setDefaultUIState()
        open(destination: destination)
    }
}

// MARK: - ThumbnailGridViewControllerDelegate
extension PDFReaderViewController: ThumbnailGridViewControllerDelegate {

    func thumbnailGridViewController(_ thumbnailGridViewController: PDFThumbnailGridViewController,
                                     didSelectPage page: PDFPage) {
        setDefaultUIState()
        open(page: page)
    }
}

extension PDFReaderViewController: BookmarkViewControllerDelegate {

    func bookmarkViewController(_ bookmarkViewController: PDFBookmarkViewController,
                                didSelectPage page: PDFPage) {
        setDefaultUIState()
        open(page: page)
    }
}
