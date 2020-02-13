//
//  ReaderNavigationController.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class ReaderNavigationController: UINavigationController {

    var postPushAction: ((ReaderNavigationController) -> Void)?
    var postPopAction: ((ReaderNavigationController) -> Void)?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        postPushAction?(self)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        defer { postPopAction?(self) }
        return super.popViewController(animated: animated)
    }
}
