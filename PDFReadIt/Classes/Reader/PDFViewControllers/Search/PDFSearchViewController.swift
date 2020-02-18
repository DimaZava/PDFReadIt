//
//  SearchViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import PDFKit
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: PDFSearchViewController,
                              didSelectSearchResult selection: PDFSelection)
}

class PDFSearchViewController: UITableViewController, PDFDocumentDelegate {

    // MARK: - Variables
    weak var delegate: SearchViewControllerDelegate?
    var pdfDocument: PDFDocument?
    var searchBar = UISearchBar()
    var searchResults = [PDFSelection]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModule))
        ]

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchBar

        let bundle = Bundle(for: Self.self)
        tableView.rowHeight = 88
        tableView.register(UINib(nibName: String(describing: PDFSearchResultsCell.self), bundle: bundle),
                           forCellReuseIdentifier: String(describing: PDFSearchResultsCell.self))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }

    deinit {
        pdfDocument?.cancelFindString()
        pdfDocument?.delegate = nil
    }

    @objc
    func dismissModule() {
        navigationController?.dismiss(animated: true)
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = searchResults[indexPath.row]
        searchBar.resignFirstResponder()
        delegate?.searchViewController(self, didSelectSearchResult: selection)
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Text"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: String(describing: PDFSearchResultsCell.self),
                                 for: indexPath) as? PDFSearchResultsCell else {
                                    fatalError("Unable to dequeue PDFSearchResultsCell")
        }

        let selection = searchResults[indexPath.row]

        guard let extendedSelection = selection.copy() as? PDFSelection else { fatalError() }
        extendedSelection.extendForLineBoundaries()

        let outline = pdfDocument?.outlineItem(for: selection)
        cell.section = outline?.label

        let page = selection.pages[0]
        cell.page = page.label

        cell.resultText = extendedSelection.string
        cell.searchText = selection.string

        return cell
    }
}

// MARK: - UISearchBarDelegate
extension PDFSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pdfDocument?.delegate = nil
        pdfDocument?.cancelFindString()

        let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        if searchText.count >= 3 {
            searchResults.removeAll()
            tableView.reloadData()
            pdfDocument?.delegate = self
            pdfDocument?.beginFindString(searchText, withOptions: .caseInsensitive)
        }
    }

    func didMatchString(_ instance: PDFSelection) {
        searchResults.append(instance)
        tableView.reloadData()
    }
}
