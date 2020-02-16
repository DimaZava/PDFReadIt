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

    unowned let pdfView: PDFView
    private let path = UIBezierPath()
    private var lastPoint = CGPoint()
    private var currentAnnotation : PDFAnnotation?
    private var pageToDrawOn: PDFPage?

    init(for pdfView: PDFView) {
        self.pdfView = pdfView
        super.init(target: nil, action: nil)
    }

    func finishDraw() {
        currentAnnotation?.paths?.forEach({ currentAnnotation?.remove($0) })
        currentAnnotation?.add(path)
        currentAnnotation = nil
        path.removeAllPoints()
        pageToDrawOn = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if pageToDrawOn != nil {
            path.removeAllPoints()
        }

        guard let position = touches.first?.location(in: pdfView),
            let numberOfTouches = event?.allTouches?.count,
            numberOfTouches == 1,
            let page = pdfView.page(for: position, nearest: false) else {
                state = .failed
                return
        }

        state = .began

        pageToDrawOn = page
        lastPoint = pdfView.convert(position, to: page)

        let border = PDFBorder()
        border.lineWidth = CGFloat(InkSettings.sharedInstance.thickness)
        border.style = .solid

        let properties = [
            .border: border,
            .color: InkSettings.sharedInstance.strokeColor
                .withAlphaComponent(CGFloat(InkSettings.sharedInstance.opacity)),
            .interiorColor: InkSettings.sharedInstance.fillColor as Any
            ] as [PDFAnnotationKey: Any]

        currentAnnotation = PDFAnnotation(bounds: page.bounds(for: .cropBox),
                                          forType: .ink,
                                          withProperties: properties)
        pageToDrawOn?.addAnnotation(currentAnnotation!)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed

        guard let position = touches.first?.location(in: pdfView),
            let page = pdfView.page(for: position, nearest: false),
            pageToDrawOn == page else { return }

        let convertedPoint = pdfView.convert(position, to: page)

        guard lastPoint != convertedPoint else { return }

        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)
        lastPoint = convertedPoint

        if InkSettings.sharedInstance.opacity < 1 {
            currentAnnotation?.paths?.forEach({ currentAnnotation?.remove($0) })
        }
        currentAnnotation?.add(path)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: pdfView),
            let page = pdfView.page(for: position, nearest: false),
            pageToDrawOn == page else {
            state = .ended
            return
        }

        let convertedPoint = pdfView.convert(position, to: page)

        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)

        finishDraw()
        state = .ended
    }
}
