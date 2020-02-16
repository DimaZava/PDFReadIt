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
    func didPrepareForShare(document: PDFDocument)
    func actionMenuViewControllerPrintDocument(_ actionMenuViewController: ActionMenuViewController)
}

final class ActionMenuViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: SelfSizedTableView!

    // MARK: - Variables
    weak var delegate: ActionMenuViewControllerDelegate?
    let pdfView: PDFView
    let documentToShare: PDFDocument
    let viewModel: ActionViewModel

    // MARK: - Lifecycle
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, documentToShare: PDFDocument, in pdfView: PDFView) {
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
        tableView.register(UINib(nibName: String(describing: PageActionTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: PageActionTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ShareActionTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ShareActionTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let desiredContentSize = tableView.intrinsicContentSize
        navigationController?.preferredContentSize = CGSize(width: desiredContentSize.width,
                                                            height: desiredContentSize.height)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension ActionMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .pages(let model):
            let controller = PagesSelectionViewController(nibName: String(describing: PagesSelectionViewController.self),
                                                          bundle: nil,
                                                          pageViewModel: model)
            navigationController?.pushViewController(controller, animated: true)
        case .shareButton:
            let selectedPages = viewModel.pageViewModel.selectedItem
            switch selectedPages {
            case .all:
                delegate?.didPrepareForShare(document: documentToShare)
            case .range(let range):
                // need to -1 because pages are indexed starting with 0
                let pages = range.compactMap { documentToShare.page(at: $0 - 1) }
                let compiledDocument = PDFDocument()
                pages.enumerated().forEach { pageTuple in
                    compiledDocument.insert(pageTuple.element, at: pageTuple.offset)
                }
                delegate?.didPrepareForShare(document: compiledDocument)
            case .currentPage(let pageIndex):
                let compiledDocument = PDFDocument()
                // need to -1 because pages are indexed starting with 0
                if let page = documentToShare.page(at: pageIndex - 1) {
                    compiledDocument.insert(page, at: 0)
                }
                delegate?.didPrepareForShare(document: compiledDocument)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PageActionTableViewCell.self), for: indexPath) as? PageActionTableViewCell else {
                fatalError("Unable to dequeue ActionTableViewCell")
            }
            cell.configure(with: model.selectedItem)
            return cell
        case .shareButton(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShareActionTableViewCell.self), for: indexPath) as? ShareActionTableViewCell else {
                fatalError("Unable to dequeue ShareActionTableViewCell")
            }
            cell.configure(with: model.item)
            return cell
        }
    }
}
