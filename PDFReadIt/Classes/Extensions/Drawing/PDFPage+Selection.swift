//
//  PDFPage+Selection.swift
//  PDFKit Demo
//
//  Created by Tim on 06/02/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import PDFKit
import UIKit

extension PDFPage {
    func annotationWithHitTest(at point: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
            if annotation.contains(point: point) {
                return annotation
            }
        }
        return nil
    }
}
