//
//  PDFRecognizer.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import PDFKit
import Foundation
import UIKit

class PDFDrawingGestureRecognizer: UIGestureRecognizer {
    unowned var pdfView: PDFView!
    private var lastPoint = CGPoint()
    private var currentAnnotation : PDFAnnotation?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            let numberOfTouches = event?.allTouches?.count,
            numberOfTouches == 1 {
            state = .began

            let position = touch.location(in: pdfView)
            let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)

            lastPoint = convertedPoint
        } else {
            state = .failed
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed

        guard let position = touches.first?.location(in: pdfView) else { return }
        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)

        let path = UIBezierPath()
        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)
        lastPoint = convertedPoint

        if currentAnnotation == nil {
            let border = PDFBorder()
            border.lineWidth = 10
            border.style = .solid

            currentAnnotation = PDFAnnotation(bounds: pdfView.currentPage!.bounds(for: .mediaBox), forType: .ink, withProperties: [
                PDFAnnotationKey.border: border,
                PDFAnnotationKey.color: UIColor.red,
                PDFAnnotationKey.interiorColor: UIColor.red,
            ])
            let pageIndex = pdfView.document!.index(for: pdfView.currentPage!)
            pdfView.document?.page(at: pageIndex)?.addAnnotation(currentAnnotation!)
        }
        currentAnnotation!.add(path)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: pdfView) else {
            state = .ended
            return
        }

        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)

        let path = UIBezierPath()
        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)

        currentAnnotation?.add(path)
        currentAnnotation = nil

        state = .ended
    }
}
