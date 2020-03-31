//
//  ActionMenuViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/04.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import PDFKit
import UIKit

protocol ActionMenuViewControllerDelegate: AnyObject {
}

final class ActionMenuViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: SelfSizedTableView!
    @IBOutlet private weak var loadingLockView: UIView!

    // MARK: - Variables
    weak var delegate: ActionMenuViewControllerDelegate?
    unowned let pdfView: PDFView
    unowned let documentToShare: PDFDocument
    let viewModel: ActionViewModel

    // MARK: - Lifecycle
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         documentToShare: PDFDocument,
         in pdfView: PDFView) {
        self.documentToShare = documentToShare
        self.pdfView = pdfView
        viewModel = ActionViewModel(with: documentToShare, in: pdfView)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Share"
        let bundle = Bundle(for: Self.self)
        tableView.register(UINib(nibName: String(describing: PageActionTableViewCell.self), bundle: bundle),
                           forCellReuseIdentifier: String(describing: PageActionTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ShareActionTableViewCell.self), bundle: bundle),
                           forCellReuseIdentifier: String(describing: ShareActionTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        loadingLockView.isUserInteractionEnabled = false
        loadingLockView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let desiredContentSize = tableView.intrinsicContentSize
        navigationController?.preferredContentSize = CGSize(width: desiredContentSize.width,
                                                            height: desiredContentSize.height)
        tableView.reloadData()
    }
}

extension ActionMenuViewController {

    func onStartedDataPreparation() {
        loadingLockView.isHidden = false
    }

    func onFinishedDataPreparation() {
        loadingLockView.isHidden = true
    }

    func didPrepareForShare(document: PDFDocument) {

        DispatchQueue.global(qos: .userInitiated).async {

            let ifNeedsToCreateTempCopy = document.documentURL == nil ||
                document.documentURL != nil &&
                (0..<document.pageCount).first { pageIndex -> Bool in
                    guard let annotations = document.page(at: pageIndex)?.annotations else { return false }
                    return !annotations
                        .filter({ $0.type == String(PDFAnnotationSubtype.ink.rawValue.dropFirst()) }).isEmpty
                } != nil

            var urlToWrite: URL
            if ifNeedsToCreateTempCopy {
                let basicName = self.documentToShare.documentURL?.lastPathComponent ?? "Document"
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                urlToWrite = path.appendingPathComponent(basicName)

                if urlToWrite.pathExtension != "pdf" {
                    urlToWrite.appendPathExtension("pdf")
                }

                document.write(to: urlToWrite)
            } else {
                // we know that documentURL is non nil because of ifNeedsToCreateTempCopy
                urlToWrite = document.documentURL!
            }

            DispatchQueue.main.async {

                self.onFinishedDataPreparation()

                let activityViewController = UIActivityViewController(activityItems: [urlToWrite],
                                                                      applicationActivities: nil)
                if ifNeedsToCreateTempCopy {
                    activityViewController.completionWithItemsHandler = { type, completed, items, error in
                        do {
                            try FileManager.default.removeItem(at: urlToWrite)
                        } catch {
                            print(error)
                        }
                    }
                }

                if UIDevice.current.userInterfaceIdiom == .phone {
                    if self.navigationController?.presentedViewController != nil {
                        self.navigationController?.dismiss(animated: true, completion: {
                            self.navigationController?.present(activityViewController, animated: true)
                        })
                    } else {
                        self.navigationController?.present(activityViewController, animated: true)
                    }
                } else if UIDevice.current.userInterfaceIdiom == .pad {
                    self.navigationController?.presentedViewController?.dismiss(animated: false)
                    self.presentPopover(activityViewController, sourcePoint: CGPoint(x: self.view.frame.maxX,
                                                                                     y: self.view.frame.midY))
                }
            }
        }
    }

    func actionMenuViewControllerPrintDocument(_ actionMenuViewController: ActionMenuViewController) {
        UIPrintInteractionController.shared.printingItem = documentToShare.dataRepresentation()
        UIPrintInteractionController.shared.present(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ActionMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .pages(let model):
            let nibName = String(describing: PagesSelectionViewController.self)
            let controller = PagesSelectionViewController(nibName: nibName,
                                                          bundle: Bundle(for: Self.self),
                                                          pageViewModel: model)
            navigationController?.pushViewController(controller, animated: true)
        case .shareButton:

            onStartedDataPreparation()
            DispatchQueue.global(qos: .userInitiated).async {

                let selectedPages = self.viewModel.pageViewModel.selectedItem
                switch selectedPages {
                case .all:
                    self.didPrepareForShare(document: self.documentToShare)
                case .range(let range):
                    // need to -1 because pages are indexed starting with 0

                    let compiledDocument = PDFDocument()

                    range.forEach { rangeElement in
                        autoreleasepool {
                            if let pageData = self.documentToShare.page(at: rangeElement - 1)?.dataRepresentation,
                                let document = PDFDocument(data: pageData),
                                document.pageCount == 1,
                                let page = document.page(at: 0) {
                                compiledDocument.insert(page, at: compiledDocument.pageCount)
                            }
                        }
                    }

                    self.didPrepareForShare(document: compiledDocument)
                case .currentPage(let pageIndex):
                    let compiledDocument = PDFDocument()
                    // need to -1 because pages are indexed starting with 0
                    if let page = self.documentToShare.page(at: pageIndex - 1) {
                        compiledDocument.insert(page, at: 0)

                        if self.pdfView.displayMode == .twoUp,
                            pageIndex - 1 != 0 {
                            if let page = self.documentToShare.page(at: pageIndex) {
                                compiledDocument.insert(page, at: 1)
                            }
                        }
                    }
                    self.didPrepareForShare(document: compiledDocument)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ActionMenuViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .pages:
            return 1
        case .shareButton:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .pages(let model):
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: String(describing: PageActionTableViewCell.self),
                                     for: indexPath) as? PageActionTableViewCell else {
                                        fatalError("Unable to dequeue ActionTableViewCell")
            }
            cell.configure(with: model.selectedItem)
            return cell
        case .shareButton(let model):
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: String(describing: ShareActionTableViewCell.self),
                                     for: indexPath) as? ShareActionTableViewCell else {
                                        fatalError("Unable to dequeue ShareActionTableViewCell")
            }
            cell.configure(with: model.item)
            return cell
        }
    }
}
