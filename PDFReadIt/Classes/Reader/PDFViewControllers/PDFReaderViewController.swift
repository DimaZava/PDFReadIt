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

@objcMembers
open class PDFReaderViewController: UIViewController {

    // MARK: - Static members
    static public func instantiateViewController(with document: PDFDocument) -> UINavigationController {
        return instantiateViewController(with: document, isNeedToOverwriteDocument: true)
    }

    static public func instantiateViewController(with document: PDFDocument,
                                                 isNeedToOverwriteDocument: Bool) -> UINavigationController {
        guard let navigationController = UIStoryboard(name: "PDFReadIt", bundle: Bundle(for: self))
            .instantiateInitialViewController() as? UINavigationController,
            let viewController = navigationController.topViewController as? Self else {
                fatalError("Unable to instantiate PDFReaderViewController")
        }
        viewController.pdfDocument = document
        viewController.isNeedToOverwriteDocument = isNeedToOverwriteDocument
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
    @IBOutlet private weak var activityIndicatorContainerView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Constants
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    private let pdfDrawer = PDFDrawer()
    private let tableOfContentsToggleSegmentedControl: UISegmentedControl = {
        let bundle = Bundle(for: PDFReaderViewController.self)
        let segmentedControl = UISegmentedControl(items: [
            UIImage(named: "PDFReaderNavigationGrid", in: bundle, compatibleWith: nil) as Any,
            UIImage(named: "PDFReaderNavigationList", in: bundle, compatibleWith: nil) as Any,
            UIImage(named: "PDFReaderBookmarkDefault", in: bundle, compatibleWith: nil) as Any
        ])
        return segmentedControl
    }()

    // MARK: - Variables
    /// Set this flag to false if you don't want to overwrite opened document (for example with drawings on it)
    var isNeedToOverwriteDocument = true
    var pdfPrevPageChangeSwipeGestureRecognizer: PDFPageChangeSwipeGestureRecognizer?
    var pdfNextPageChangeSwipeGestureRecognizer: PDFPageChangeSwipeGestureRecognizer?
    private(set) var pdfDocument: PDFDocument?
    private var bookmarkButton: UIBarButtonItem!
    private var searchNavigationController: UINavigationController?
    lazy private var drawingGestureRecognizer: DrawingGestureRecognizer = {
        let recognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(recognizer)
        recognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
        return recognizer
    }()
    private var shouldUpdatePDFScrollPosition = true

    open var postDismissAction: ((PDFReaderViewController) -> Void)?

    // MARK: - Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEvents()
        setDefaultUIState()
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustThumbnailViewHeight()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }

    override open func willTransition(to newCollection: UITraitCollection,
                                      with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.adjustThumbnailViewHeight()
        })
    }

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

    // MARK: - UI
    func setupUI() {

        pdfView.document = pdfDocument
        titleLabel.text = pdfDocument?.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ??
            pdfDocument?.documentURL?.lastPathComponent

        if titleLabel.text == nil {
            titleLabel.isHidden = true
        }

        pdfView.displayMode = .twoUp
        pdfView.displaysAsBook = true
        pdfView.displayDirection = .horizontal
        pdfView.autoScales = true

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
        tableOfContentsToggleSegmentedControl.addTarget(self,
                                                        action: #selector(toggleTableOfContentsView(_:)),
                                                        for: .valueChanged)
    }

    // MARK: - Notification Events
    func pdfViewPageChanged(_ notification: Notification) {
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updateBookmarkStatus()
        updatePageNumberLabel()
    }

    // MARK: - Actions
    func resume(_ sender: UIBarButtonItem) {
        setDefaultUIState()
    }

    func back(_ sender: UIBarButtonItem) {
        dismissModule(animated: true)
    }

    func showTableOfContents(_ sender: UIBarButtonItem) {
        showTableOfContents()
    }

    func showActionMenu(_ sender: UIBarButtonItem) {

        guard let documentToShare = pdfDocument else {
            print("Unable to share: pdfDocument is nil")
            return
        }

        let viewController = ActionMenuViewController(nibName: String(describing: ActionMenuViewController.self),
                                                      bundle: Bundle(for: Self.self),
                                                      documentToShare: documentToShare,
                                                      in: pdfView)
        viewController.delegate = self

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender
        navigationController.popoverPresentationController?.permittedArrowDirections = .up
        navigationController.popoverPresentationController?.delegate = self
        present(navigationController, animated: true)
    }

    func annotateAction(_ sender: UIBarButtonItem) {
        enableAnnotationMode()
    }

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

    func addOrRemoveBookmark(_ sender: UIBarButtonItem) {

        guard let documentURL = pdfDocument?.documentURL?.absoluteString,
            let currentPage = pdfView.currentPage,
            let pageIndex = pdfDocument?.index(for: currentPage) else { return }

        let bundle = Bundle(for: Self.self)
        var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] ?? [Int]()
        if let index = bookmarks.firstIndex(of: pageIndex) {
            bookmarks.remove(at: index)
            UserDefaults.standard.set(bookmarks, forKey: documentURL)
            bookmarkButton.image = UIImage(named: "PDFReaderBookmarkDefault", in: bundle, compatibleWith: nil)
        } else {
            UserDefaults.standard.set((bookmarks + [pageIndex]).sorted(), forKey: documentURL)
            bookmarkButton.image = UIImage(named: "PDFReaderBookmarkAdded", in: bundle, compatibleWith: nil)
        }
    }

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

    func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        if navigationController.navigationBar.alpha > 0 {
            hideBars()
        } else {
            showBars()
        }
    }

    func dismissModule(animated: Bool = true) {

        let dismissBlock = {
            switch self.parent {
            case let navController as UINavigationController where !navController.viewControllers.isEmpty &&
                navController.viewControllers.first != self:
                navController.popViewController(animated: animated)
            case _ where self.parent?.presentingViewController != nil ||
                self.parent?.popoverPresentationController != nil:
                if self.navigationController == nil {
                    self.dismiss(animated: animated)
                } else {
                    self.navigationController?.dismiss(animated: animated)
                }
            case let navigationController as UINavigationController where !navigationController.viewControllers.isEmpty:
                navigationController.popViewController(animated: animated)
            default:
                self.dismiss(animated: animated)
            }
            self.postDismissAction?(self)
        }

        if isNeedToOverwriteDocument,
            let documentURL = pdfDocument?.documentURL,
            documentURL.isFileURL {

            showWaitingView()

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if FileManager.default.fileExists(atPath: documentURL.path) {
                        try FileManager.default.removeItem(at: documentURL)
                    }
                    self.pdfDocument?.write(to: documentURL)
                } catch {
                    print(error)
                }

                DispatchQueue.main.async {
                    self.hideWaitingView()
                    dismissBlock()
                }
            }
        } else {
            dismissBlock()
        }
    }

    func showWaitingView() {
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = false }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        activityIndicatorContainerView.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideWaitingView() {
        activityIndicator.stopAnimating()
        activityIndicatorContainerView.isHidden = true
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
    }

    func showBars(needsToHideNavigationBar: Bool = true) {
        guard let navigationController = navigationController else { return }
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            if needsToHideNavigationBar {
                navigationController.navigationBar.alpha = 1
            }
            self.pdfThumbnailViewContainer.alpha = 1
            self.titleLabelContainer.alpha = 1
            self.pageNumberLabelContainer.alpha = 1
        }
    }

    func hideBars(needsToHideNavigationBar: Bool = true) {
        guard let navigationController = navigationController else { return }
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            if needsToHideNavigationBar {
                navigationController.navigationBar.alpha = 0
            }
            self.pdfThumbnailViewContainer.alpha = 0
            self.titleLabelContainer.alpha = 0
            self.pageNumberLabelContainer.alpha = 0
        }
    }

    // MARK: - Other
    func setDefaultUIState() {

        let bundle = Bundle(for: Self.self)

        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "PDFReaderNavigationBack", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(back(_:))),
            UIBarButtonItem(barButtonSystemItem: .bookmarks,
                            target: self,
                            action: #selector(showTableOfContents(_:))),
            UIBarButtonItem(barButtonSystemItem: .search,
                            target: self,
                            action: #selector(showSearchView(_:)))
        ]

        bookmarkButton =
            UIBarButtonItem(image: UIImage(named: "PDFReaderBookmarkDefault", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(addOrRemoveBookmark(_:)))

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "PDFReaderAnnotation", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(annotateAction(_:))),
            UIBarButtonItem(barButtonSystemItem: .action,
                            target: self,
                            action: #selector(showActionMenu(_:))),
            bookmarkButton,
            UIBarButtonItem(image: UIImage(named: "PDFReaderBrightness", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(showAppearanceMenu(_:)))
        ]

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
}

// MARK: - PDF Navigation
extension PDFReaderViewController {

    func open(page: PDFPage) {
        pdfView.go(to: page)
    }

    func selectAndOpen(_ selection: PDFSelection) {
        selection.color = .yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
    }

    func open(destination: PDFDestination) {
        pdfView.go(to: destination)
    }

    // MARK: Drawing
    func addDrawingGestureRecognizerToPDFView() {
        drawingGestureRecognizer.isEnabled = true
    }

    func removeDrawingGestureRecognizerFromPDFView() {
        drawingGestureRecognizer.isEnabled = false
    }
}

// MARK: - Private extension of PDFReaderViewController
private extension PDFReaderViewController {

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    func fixPDFViewScrollPosition() {
        guard let page = pdfView.document?.page(at: 0) else { return }
        pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).height)))
    }

    func showTableOfContents() {
        view.exchangeSubview(at: 0, withSubviewAt: 1)
        view.exchangeSubview(at: 0, withSubviewAt: 2)

        let bundle = Bundle(for: Self.self)
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "PDFReaderNavigationBack", in: bundle, compatibleWith: nil),
                            style: .plain,
                            target: self,
                            action: #selector(back(_:))),
            UIBarButtonItem(customView: tableOfContentsToggleSegmentedControl)
        ]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Resume", comment: ""),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(resume(_:)))

        pdfThumbnailViewContainer.alpha = 0
        toggleTableOfContentsView(tableOfContentsToggleSegmentedControl)
        barHideOnTapGestureRecognizer.isEnabled = false
    }

    func adjustThumbnailViewHeight() {
        pdfThumbnailViewHeightConstraint.constant = 44 + view.safeAreaInsets.bottom
    }

    func updateBookmarkStatus() {
        guard let documentURL = pdfDocument?.documentURL?.absoluteString,
            let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage,
            let index = pdfDocument?.index(for: currentPage) else { return }

        let bundle = Bundle(for: Self.self)
        let imageName = bookmarks.contains(index) ? "PDFReaderBookmarkAdded" : "PDFReaderBookmarkDefault"
        bookmarkButton.image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
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
            let currentPagesIndexes = (index > 0 && index < pageCount) ? "\(index + 1)-\(index + 2)" : "\(index + 1)"
            pageNumberLabel.text = String("\(currentPagesIndexes)/\(pageCount)")
        }
    }
}
