//
//  OutlineViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import PDFKit

protocol OutlineViewControllerDelegate: AnyObject {
    func outlineViewController(_ outlineViewController: PDFOutlineViewController,
                               didSelectOutlineAt destination: PDFDestination)
}

class PDFOutlineViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Variables
    weak var delegate: OutlineViewControllerDelegate?
    var pdfDocument: PDFDocument?
    var toc = [PDFOutline]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: PDFOutlineCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: PDFOutlineCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        if let root = pdfDocument?.outlineRoot {
            var stack = [root]
            while !stack.isEmpty {
                let current = stack.removeLast()
                if let label = current.label, !label.isEmpty {
                    toc.append(current)
                }
                for i in (0..<current.numberOfChildren).reversed() {
                    stack.append(current.child(at: i)!)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension PDFOutlineViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let outline = toc[indexPath.row]
        if let destination = outline.destination {
            delegate?.outlineViewController(self, didSelectOutlineAt: destination)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PDFOutlineViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toc.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PDFOutlineCell.self), for: indexPath) as! PDFOutlineCell
        let outline = toc[indexPath.row]

        cell.label = outline.label
        cell.pageLabel = outline.destination?.page?.label

        var indentationLevel = -1
        var parent = outline.parent
        while let _ = parent {
            indentationLevel += 1
            parent = parent?.parent
        }
        cell.indentationLevel = indentationLevel

        return cell
    }
}
