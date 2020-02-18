//
//  PDFViewGestureRecognizer.swift
//  BookReader
//
//  Created by Dmitryj on 03.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class PDFViewGestureRecognizer: UIGestureRecognizer {

    var isTracking = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}
