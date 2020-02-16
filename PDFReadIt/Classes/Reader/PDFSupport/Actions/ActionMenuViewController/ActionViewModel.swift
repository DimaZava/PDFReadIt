//
//  ActionViewModel.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import PDFKit

final class ActionViewModel {

    enum Section {
        case pages(PageViewModel)
//        case annotations
        case shareButton(ShareViewModel)

        var title: String? {
            switch self {
            case .pages:
                return "Pages".uppercased()
//            case .annotations:
//                return "Annotations".uppercased()
            case .shareButton:
                return nil
            }
        }
    }

    // MARK: - Constants
    let sections: [Section]

    let pageViewModel: PageViewModel
    let shareViewModel: ShareViewModel

    init(with pdfDocument: PDFDocument, in pdfView: PDFView) {
        pageViewModel = PageViewModel(with: pdfDocument, in: pdfView)
        shareViewModel = ShareViewModel()
        sections = [
            .pages(pageViewModel),
            .shareButton(shareViewModel)
        ]
    }
}

final class PageViewModel {

    enum PageSelectionItem: Equatable {
        case all(ClosedRange<Int>)
        case range(ClosedRange<Int>)
        case currentPage(Int)
        //case annotatedPages

        var title: String {
            switch self {
            case .all(let range):
                return "All (\(range.lowerBound) - \(range.upperBound))"
            case .range(let range):
                return "Pages " + "\(range.lowerBound) - \(range.upperBound)"
            case .currentPage:
                return "Current page"
            }
        }
    }

    var selectedItem: PageSelectionItem {
        didSet {
            print("selected pages = \(selectedItem)")
        }
    }
    var items: [PageSelectionItem]

    init(with pdfDocument: PDFDocument, in pdfView: PDFView) {
        guard let currentPage = pdfView.currentPage else { fatalError("PDFDocument unitialized for PDF View") }
        let allPagesRange = (pdfDocument.pageCount > 0 ? 1 : 0)...pdfDocument.pageCount
        let customPagesRange = (pdfDocument.pageCount > 0 ? 1 : 0)...(pdfDocument.pageCount > 0 ? 1 : 0)
        selectedItem = .all(allPagesRange)
        items = [
            .all(allPagesRange),
            .currentPage(pdfDocument.index(for: currentPage) + 1), // needs to conform visual representation
            .range(customPagesRange)
        ]
    }
}

final class ShareViewModel {

    struct ShareItem {
        let title: String
    }

    var item: ShareItem

    init() {
        item = ShareItem(title: "Share")
    }
}
