//
//  UIView+Extensions.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 13.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension UIView {

    /// Take screenshot of view (if applicable).
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Anchor all sides of the view into it's superview.
    @available(iOS 9, *)
    func fillToSuperview(respectSafeArea: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            let left = leftAnchor.constraint(equalTo: superview.leftAnchor)
            let right = rightAnchor.constraint(equalTo: superview.rightAnchor)
            let top = topAnchor.constraint(equalTo: respectSafeArea ?
                superview.safeAreaLayoutGuide.topAnchor :
                superview.topAnchor)
            let bottom = bottomAnchor.constraint(equalTo: respectSafeArea ?
                superview.safeAreaLayoutGuide.bottomAnchor :
                superview.bottomAnchor)
            NSLayoutConstraint.activate([left, right, top, bottom])
        }
    }
}
