//
//  SelfSizedTableView.swift
//  AirLST
//
//  Created by Dmitryj on 12/08/2019.
//  Copyright © 2019 AirLST. All rights reserved.
//

import UIKit

final class SelfSizedTableView: UITableView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
}
