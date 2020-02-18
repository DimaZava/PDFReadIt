//
//  BookViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import MessageUI
import PDFKit
import UIKit

class PDFReaderViewController: UIViewController {

    // MARK: - Static members
    @objc
    static func instantiateViewController(with document: PDFDocument) -> UINavigationController {
        guard let navigationController = UIStoryboard(name: "PDFReadIt", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let viewController = navigationController.topViewController as? Self else {
                fatalError("Unable to instantiate PDFReaderViewController")
        }
        viewController.pdfDocument = document
        return navigationController
    }

    // MARK: - Outlets
    @IBOutlet private weak var pdfView: PDFView!
    @IBOutlet private weak var pdfThumbnailViewContainer: UIView!
    @IBOutlet private weak var pdfThumbnailView: PDFThumbnailView!
    @IBOutlet private weak var pdfThumbnailViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleLabelContainer: UIView!
    @IBOutlet private weak var pageNumberLabel: UILabel!
    @IBOutlet private weak var pageNumberLabelContainer: UIView!

    @IBOutlet private weak var thumbnailGridViewConainer: UIView!
    @IBOutlet private weak var outlineViewConainer: UIView!
    @IBOutlet private weak var bookmarkViewConainer: UIView!

    // MARK: - Constants
    private let tableOfContentsToggleSegmentedControl = UISegmentedControl(items: [#imageLiteral(resourceName: "pdf_reader_navigation_grid"), #imageLiteral(resourceName: "pdf_reader_navigation_list"), #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_normal")])
    private let pdfDrawer = PDFDrawer()
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()

    // MARK: - Variables
    @objc var pdfDocument: PDFDocument?
    var bookmarkButton: UIBarButtonItem!
    var searchNavigationController: UINavigationController?
    var inkSettingsViewController: InkSettingsViewController?
    var pdfPrevPageChangeSwipeGestureRecognizer: PDFPageChangeSwipeGestureRecognizer?
    var pdfNextPageChangeSwipeGestureRecognizer: PDFPageChangeSwipeGestureRecognizer?
    lazy var drawingGestureRecognizer: DrawingGestureRecognizer = {
        let recognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(recognizer)
        recognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
        return recognizer
    }()
    private var shouldUpdatePDFScrollPosition = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEvents()
        resumeDefaultState()
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }

    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }

    func setupUI() {

        pdfView.document = pdfDocument
        titleLabel.text = pdfDocument?.documentAttributes?["Title"] as? String

        pdfView.displayMode = .twoUp
        pdfView.displaysAsBook = true
        pdfView.displayDirection = .horizontal
        pdfView.autoScales = true
        //pdfView.usePageViewController(true)

        //pdfView.addGestureRecognizer(pdfViewGestureRecognizer)

        let pdfPrevPageChangeSwipeGestureRecognizer = PDFPageChangeSwipeGestureRecognizer(pdfView: pdfView)
        pdfPrevPageChangeSwipeGestureRecognizer.direction = .left
        pdfView.addGestureRecognizer(pdfPrevPageChangeSwipeGestureRecognizer)
        self.pdfPrevPageChangeSwipeGestureRecognizer = pdfPrevPageChangeSwipeGestureRecognizer

        let pdfNextPageChangeSwipeGestureRecognizer = PDFPageChangeSwipeGestureRecognizer(pdfView: pdfView)
        pdfNextPageChangeSwipeGestureRecognizer.direction = .right
        pdfView.addGestureRecognizer(pdfNextPageChangeSwipeGestureRecognizer)
        self.pdfNextPageChangeSwipeGestureRecognizer = pdfNextPageChangeSwipeGestureRecognizer

        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.pdfView = pdfView

        titleLabelContainer.layer.cornerRadius = 4
        pageNumberLabelContainer.layer.cornerRadius = 4
    }

    func setupEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pdfViewPageChanged(_:)),
                                               name: .PDFViewPageChanged,
                                               object: nil)

        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizedToggleVisibility(_:)))
        barHideOnTapGestureRecognizer.numberOfTapsRequired = 1
        barHideOnTapGestureRecognizer.delegate = self
        pdfView.addGestureRecognizer(barHideOnTapGestureRecognizer)

        for segmentIndex in 0..<tableOfContentsToggleSegmentedControl.numberOfSegments {
            tableOfContentsToggleSegmentedControl.setWidth(50.0, forSegmentAt: segmentIndex)
        }
        tableOfContentsToggleSegmentedControl.selectedSegmentIndex = 0
        tableOfContentsToggleSegmentedControl.addTarget(self, action: #selector(toggleTableOfContentsView(_:)), for: .valueChanged)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustThumbnailViewHeight()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.adjustThumbnailViewHeight()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PDFThumbnailGridViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        } else if let viewController = segue.destination as? PDFOutlineViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        } else if let viewController = segue.destination as? PDFBookmarkViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        }
    }

    // MARK: - Actions
    @objc
    func resume(_ sender: UIBarButtonItem) {
        resumeDefaultState()
    }

    @objc
    func back(_ sender: UIBarButtonItem) {
        dismissModule(animated: true)
    }

    @objc
    func showTableOfContents(_ sender: UIBarButtonItem) {
        showTableOfContents()
    }

    @objc
    func showActionMenu(_ sender: UIBarButtonItem) {

        guard let documentToShare = pdfDocument else {
            print("Unable to share: pdfDocument is nil")
            return
        }

        let viewController = ActionMenuViewController(nibName: String(describing: ActionMenuViewController.self),
                                                      bundle: nil,
                                                      documentToShare: documentToShare,
                                                      in: pdfView)
        viewController.delegate = self

        let navigationController = ReaderNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender
        navigationController.popoverPresentationController?.permittedArrowDirections = .up
        navigationController.popoverPresentationController?.delegate = self
        present(navigationController, animated: true)
    }

    @objc
    func annotateAction(_ sender: UIBarButtonItem) {
        enableAnnotationMode()
    }

    @objc
    func showAppearanceMenu(_ sender: UIBarButtonItem) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "AppearanceViewController")
            as? AppearanceViewController else { return }
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize(width: 300, height: 44)
        viewController.popoverPresentationController?.barButtonItem = sender
        viewController.popoverPresentationController?.permittedArrowDirections = .up
        viewController.popoverPresentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
    }

    @objc
    func showSearchView(_ sender: UIBarButtonItem) {
        if let searchNavigationController = self.searchNavigationController {
            present(searchNavigationController, animated: true, completion: nil)
        } else if let navigationController =
            storyboard?.instantiateViewController(withIdentifier: "PDFSearchViewController") as? UINavigationController,
            let searchViewController = navigationController.topViewController as? PDFSearchViewController {
            searchViewController.pdfDocument = pdfDocument
            searchViewController.delegate = self
            present(navigationController, animated: true, completion: nil)

            searchNavigationController = navigationController
        }
    }

    @objc
    func addOrRemoveBookmark(_ sender: UIBarButtonItem) {

        guard let documentURL = pdfDocument?.documentURL?.absoluteString else { return }

        var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] ?? [Int]()
        if let currentPage = pdfView.currentPage,
            let pageIndex = pdfDocument?.index(for: currentPage) {
            if let index = bookmarks.firstIndex(of: pageIndex) {
                bookmarks.remove(at: index)
                UserDefaults.standard.set(bookmarks, forKey: documentURL)
                bookmarkButton.image = #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_normal")
            } else {
                UserDefaults.standard.set((bookmarks + [pageIndex]).sorted(), forKey: documentURL)
                bookmarkButton.image = #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_added")
            }
        }
    }

    @objc
    func toggleTableOfContentsView(_ sender: UISegmentedControl) {
        pdfView.isHidden = true
        titleLabelContainer.alpha = 0
        pageNumberLabelContainer.alpha = 0

        if tableOfContentsToggleSegmentedControl.selectedSegmentIndex == 0 {
            thumbnailGridViewConainer.isHidden = false
            outlineViewConainer.isHidden = true
            bookmarkViewConainer.isHidden = true
        } else if tableOfContentsToggleSegmentedControl.selectedSegmentIndex == 1 {
            thumbnailGridViewConainer.isHidden = true
            outlineViewConainer.isHidden = false
            bookmarkViewConainer.isHidden = true
        } else {
            thumbnailGridViewConainer.isHidden = true
            outlineViewConainer.isHidden = true
            bookmarkViewConainer.isHidden = false
        }
    }

    @objc
    func pdfViewPageChanged(_ notification: Notification) {
        //pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updateBookmarkStatus()
        updatePageNumberLabel()
    }

    @objc
    func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        if let navigationController = navigationController {
            if navigationController.navigationBar.alpha > 0 {
                hideBars()
            } else {
                showBars()
            }
        }
    }

    @objc
    public func dismissModule(animated: Bool = true) {
        switch parent {
        case let navigationController as UINavigationController where !navigationController.viewControllers.isEmpty &&
            navigationController.viewControllers.first != self:
            navigationController.popViewController(animated: animated)
        case _ where parent?.presentingViewController != nil || parent?.popoverPresentationController != nil:
            if navigationController == nil {
                dismiss(animated: animated)
            } else {
                navigationController?.dismiss(animated: animated)
            }
        case let navigationController as UINavigationController where !navigationController.viewControllers.isEmpty:
            navigationController.popViewController(animated: animated)
        default:
            dismiss(animated: animated)
        }
    }

    // MARK: - Other
    func resumeDefaultState() {

        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "pdf_reader_navigation_back"), style: .plain, target: self, action: #selector(back(_:)))
        let contentsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showTableOfContents(_:)))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchView(_:)))
        navigationItem.leftBarButtonItems = [backButton, contentsButton, searchButton]

        let brightnessButton = UIBarButtonItem(image: #imageLiteral(resourceName: "pdf_reader_navigation_brightness"), style: .plain, target: self, action: #selector(showAppearanceMenu(_:)))
        bookmarkButton = UIBarButtonItem(image: #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_normal"), style: .plain, target: self, action: #selector(addOrRemoveBookmark(_:)))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionMenu(_:)))
        let annotateButton = UIBarButtonItem(image: UIImage(named: "pdf_reader_annotation"), style: .plain, target: self, action: #selector(annotateAction(_:)))
        navigationItem.rightBarButtonItems = [annotateButton, actionButton, bookmarkButton, brightnessButton]

        pdfThumbnailViewContainer.alpha = 1

        pdfView.isHidden = false
        titleLabelContainer.alpha = 1
        pageNumberLabelContainer.alpha = 1
        thumbnailGridViewConainer.isHidden = true
        outlineViewConainer.isHidden = true

        barHideOnTapGestureRecognizer.isEnabled = true

        updateBookmarkStatus()
        updatePageNumberLabel()
    }

    func addDrawingGestureRecognizerToPDFView() {
        drawingGestureRecognizer.isEnabled = true
    }

    func removeDrawingGestureRecognizerFromPDFView() {
        drawingGestureRecognizer.isEnabled = false
    }

    func showBars(needsToHideNavigationBar: Bool = true) {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                if needsToHideNavigationBar {
                    navigationController.navigationBar.alpha = 1
                }
                self.pdfThumbnailViewContainer.alpha = 1
                self.titleLabelContainer.alpha = 1
                self.pageNumberLabelContainer.alpha = 1
            }
        }
    }

    func hideBars(needsToHideNavigationBar: Bool = true) {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                if needsToHideNavigationBar {
                    navigationController.navigationBar.alpha = 0
                }
                self.pdfThumbnailViewContainer.alpha = 0
                self.titleLabelContainer.alpha = 0
                self.pageNumberLabelContainer.alpha = 0
            }
        }
    }
}

// MARK: - Private extension of PDFReaderViewController
private extension PDFReaderViewController {

    func showTableOfContents() {
        view.exchangeSubview(at: 0, withSubviewAt: 1)
        view.exchangeSubview(at: 0, withSubviewAt: 2)

        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "pdf_reader_navigation_back"), style: .plain, target: self, action: #selector(back(_:)))
        let tableOfContentsToggleBarButton = UIBarButtonItem(customView: tableOfContentsToggleSegmentedControl)
        let resumeBarButton = UIBarButtonItem(title: NSLocalizedString("Resume", comment: ""), style: .plain, target: self, action: #selector(resume(_:)))
        navigationItem.leftBarButtonItems = [backButton, tableOfContentsToggleBarButton]
        navigationItem.rightBarButtonItems = [resumeBarButton]

        pdfThumbnailViewContainer.alpha = 0

        toggleTableOfContentsView(tableOfContentsToggleSegmentedControl)

        barHideOnTapGestureRecognizer.isEnabled = false
    }

    func adjustThumbnailViewHeight() {
        self.pdfThumbnailViewHeightConstraint.constant = 44 + self.view.safeAreaInsets.bottom
    }

    func updateBookmarkStatus() {
        if let documentURL = pdfDocument?.documentURL?.absoluteString,
            let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage,
            let index = pdfDocument?.index(for: currentPage) {
            bookmarkButton.image = bookmarks.contains(index) ? #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_added") : #imageLiteral(resourceName: "pdf_reader_navigation_bookmark_normal")
        }
    }

    func updatePageNumberLabel() {
        guard let currentPage = pdfView.visiblePages.first,
            let index = pdfDocument?.index(for: currentPage),
            let pageCount = pdfDocument?.pageCount else {
                pageNumberLabel.text = nil
                return
        }

        if pdfView.displayMode == .singlePage || pdfView.displayMode == .singlePageContinuous {
            pageNumberLabel.text = String("\(index + 1)/\(pageCount)")
        } else {
            let currentPagesIndexes = (index != pageCount && index != 0) ? "\(index + 1)-\(index + 2)" : "\(index + 1)"
            pageNumberLabel.text = String("\(currentPagesIndexes)/\(pageCount)")
        }
    }
}

// MARK: - PDFViewDelegate
extension PDFReaderViewController: PDFViewDelegate {
}

// MARK: - UIPopoverPresentationControllerDelegate
extension PDFReaderViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension PDFReaderViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - ActionMenuViewControllerDelegate
extension PDFReaderViewController: ActionMenuViewControllerDelegate {

    func didPrepareForShare(document: PDFDocument) {

        guard MFMailComposeViewController.canSendMail() else {
            print("This device doesn't support MFMailComposeViewController")
            return
        }

        let documentToProceed: PDFDocument
        if document.documentURL == nil {
            let basicName = pdfDocument?.documentURL?.lastPathComponent ?? "Document.pdf"
            let urlToWrite = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(basicName)
            document.write(to: urlToWrite)
            documentToProceed = PDFDocument(url: urlToWrite)!
        } else {
            documentToProceed = document
        }

        guard let lastPathComponent = documentToProceed.documentURL?.lastPathComponent,
            let documentAttributes = documentToProceed.documentAttributes,
            let attachmentData = documentToProceed.dataRepresentation() else { return }

        let mailComposeViewController = MFMailComposeViewController()

        if let title = documentAttributes[PDFDocumentAttribute.titleAttribute] as? String {
            mailComposeViewController.setSubject(title)
        }
        mailComposeViewController.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: lastPathComponent)

        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.modalPresentationStyle = .formSheet
        mailComposeViewController.isModalInPopover = true

        if navigationController?.presentedViewController != nil {
            navigationController?.dismiss(animated: true, completion: {
                self.navigationController?.present(mailComposeViewController, animated: true)
            })
        } else {
            navigationController?.present(mailComposeViewController, animated: true)
        }
    }

    func actionMenuViewControllerPrintDocument(_ actionMenuViewController: ActionMenuViewController) {
        let printInteractionController = UIPrintInteractionController.shared
        printInteractionController.printingItem = pdfDocument?.dataRepresentation()
        printInteractionController.present(animated: true)
    }
}

extension PDFReaderViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == barHideOnTapGestureRecognizer {
            return true
        }
        return false
    }
}

// MARK: - SearchViewControllerDelegate
extension PDFReaderViewController: SearchViewControllerDelegate {

    func searchViewController(_ searchViewController: PDFSearchViewController, didSelectSearchResult selection: PDFSelection) {
        selection.color = .yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
        showBars()
    }
}

// MARK: - OutlineViewControllerDelegate
extension PDFReaderViewController: OutlineViewControllerDelegate {

    func outlineViewController(_ outlineViewController: PDFOutlineViewController, didSelectOutlineAt destination: PDFDestination) {
        resumeDefaultState()
        pdfView.go(to: destination)
    }
}

// MARK: - ThumbnailGridViewControllerDelegate
extension PDFReaderViewController: ThumbnailGridViewControllerDelegate {

    func thumbnailGridViewController(_ thumbnailGridViewController: PDFThumbnailGridViewController, didSelectPage page: PDFPage) {
        resumeDefaultState()
        pdfView.go(to: page)
    }
}

extension PDFReaderViewController: BookmarkViewControllerDelegate {

    func bookmarkViewController(_ bookmarkViewController: PDFBookmarkViewController, didSelectPage page: PDFPage) {
        resumeDefaultState()
        pdfView.go(to: page)
    }
}
