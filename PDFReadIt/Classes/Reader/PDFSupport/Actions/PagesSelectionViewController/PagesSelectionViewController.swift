//
//  PagesSelectionViewController.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class PagesSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: SelfSizedTableView!

    let pageViewModel: PageViewModel
    var isRangePickerVisible = false

    // MARK: - Lifecycle
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, pageViewModel: PageViewModel) {
        self.pageViewModel = pageViewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let desiredContentSize = tableView.intrinsicContentSize
        navigationController?.preferredContentSize = CGSize(width: desiredContentSize.width,
                                                            height: desiredContentSize.height)
    }
}

private extension PagesSelectionViewController {

    func setupInitialState() {

        if case .range = pageViewModel.selectedItem {
            isRangePickerVisible = true
        }

        let bundle = Bundle(for: Self.self)
        tableView.register(UINib(nibName: String(describing: PagesSelectionTableViewCell.self), bundle: bundle),
                           forCellReuseIdentifier: String(describing: PagesSelectionTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: PagesRangeSelectionTableViewCell.self), bundle: bundle),
                           forCellReuseIdentifier: String(describing: PagesRangeSelectionTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PagesSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageViewModel.selectedItem = pageViewModel.items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let isRangePickerPreviousState = isRangePickerVisible
        if case .range = pageViewModel.selectedItem {
            isRangePickerVisible = true
        } else {
            isRangePickerVisible = false
        }
        if let indexPathsToReload = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPathsToReload, with: .automatic)

            if isRangePickerPreviousState != isRangePickerVisible {
                let desiredContentSize = tableView.intrinsicContentSize
                navigationController?.preferredContentSize = CGSize(width: desiredContentSize.width,
                                                                    height: desiredContentSize.height)
            }
        }
    }
}

extension PagesSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < pageViewModel.items.count {
            return UITableView.automaticDimension
        }
        return isRangePickerVisible ? 160 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageViewModel.items.count + 1 // 1 for picker
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row < pageViewModel.items.count {
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: String(describing: PagesSelectionTableViewCell.self),
                                     for: indexPath) as? PagesSelectionTableViewCell else {
                                        fatalError("Unable to dequeue PagesSelectionTableViewCell")
            }
            cell.configure(for: pageViewModel.items[indexPath.row], in: pageViewModel)
            return cell
        } else {
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: String(describing: PagesRangeSelectionTableViewCell.self),
                                     for: indexPath) as? PagesRangeSelectionTableViewCell,
                case let .all(range) = pageViewModel.items.first (where: { pagesSelectionItem -> Bool in
                    if case .all = pagesSelectionItem {
                        return true
                    } else {
                        return false
                    }
                }) else {
                    fatalError("Unable to dequeue PagesRangeSelectionTableViewCell")
            }

            cell.configure(for: pageViewModel.items[indexPath.row - 1], documentRange: range)
            cell.delegate = self
            return cell
        }
    }
}

extension PagesSelectionViewController: PagesRangeSelectionTableViewCellDelegate {

    func didUpdate(range: ClosedRange<Int>) {
        guard let indexToUpdate = pageViewModel.items.firstIndex (where: { pagesSelectionItem -> Bool in
            if case .range = pagesSelectionItem {
                return true
            } else {
                return false
            }
        }) else {
            print("Error. There should be .range enum")
            return
        }

        pageViewModel.selectedItem = .range(range)
        pageViewModel.items[indexToUpdate] = .range(range)

        tableView.reloadRows(at: [IndexPath(row: indexToUpdate, section: 0)], with: .automatic)
    }
}
