//
//  ThumbnailGridViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import PDFKit

protocol ThumbnailGridViewControllerDelegate: AnyObject {
    func thumbnailGridViewController(_ thumbnailGridViewController: PDFThumbnailGridViewController,
                                     didSelectPage page: PDFPage)
}

class PDFThumbnailGridViewController: UICollectionViewController {

    // MARK: - Constants
    let thumbnailCache = NSCache<NSNumber, UIImage>()
    private let downloadQueue = DispatchQueue(label: "com.kishikawakatsumi.pdfviewer.thumbnail")

    // MARK: - Variables
    weak var delegate: ThumbnailGridViewControllerDelegate?
    var pdfDocument: PDFDocument?
    var cellSize: CGSize {
        guard let collectionView = collectionView else { return CGSize(width: 100, height: 150) }
        var width = collectionView.frame.width
        var height = collectionView.frame.height
        if width > height {
            swap(&width, &height)
        }
        width = (width - 20 * 4) / 3
        height = width * 1.5
        return CGSize(width: width, height: height)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundView = UIView()
        backgroundView.backgroundColor = .gray
        collectionView?.backgroundView = backgroundView
        collectionView?.register(UINib(nibName: String(describing: PDFThumbnailGridCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: "Cell")
    }

    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                            for: indexPath) as? PDFThumbnailGridCell else {
                                                                fatalError("Unable to dequeue PDFThumbnailGridCell")
        }

        guard let page = pdfDocument?.page(at: indexPath.item) else { return cell }
        let pageNumber = indexPath.item
        cell.pageNumber = pageNumber

        let key = NSNumber(value: pageNumber)
        if let thumbnail = thumbnailCache.object(forKey: key) {
            cell.image = thumbnail
        } else {
            let size = cellSize
            downloadQueue.async {
                let thumbnail = page.thumbnail(of: size, for: .cropBox)
                self.thumbnailCache.setObject(thumbnail, forKey: key)
                if cell.pageNumber == pageNumber {
                    DispatchQueue.main.async {
                        cell.image = thumbnail
                    }
                }
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let page = pdfDocument?.page(at: indexPath.item) {
            delegate?.thumbnailGridViewController(self, didSelectPage: page)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PDFThumbnailGridViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
