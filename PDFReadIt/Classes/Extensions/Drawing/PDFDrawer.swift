//
//  PDFDrawer.swift
//  PDFKit Demo
//
//  Created by Tim on 31/01/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import Foundation
import PDFKit

class PDFDrawer {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    private var currentAnnotation: DrawingAnnotation?
    private var currentPage: PDFPage?
}

extension PDFDrawer: DrawingGestureRecognizerDelegate {

    func gestureRecognizerBegan(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        beginAnnotating(for: page, in: location)
    }

    func gestureRecognizerMoved(_ location: CGPoint) {

        guard let currentPage = currentPage else { return }

        let nearestPage = pdfView.page(for: location, nearest: true) ?? currentPage

        if currentPage != nearestPage {
            endAnnotating(for: currentPage)
            self.currentPage = nearestPage
            beginAnnotating(for: nearestPage, in: location)
        }
        let convertedPoint = pdfView.convert(location, to: nearestPage)

        // Erasing
        if InkSettings.sharedInstance.tool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: nearestPage)
            return
        }

        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: nearestPage)
    }

    func gestureRecognizerEnded(_ location: CGPoint) {

        guard let currentPage = currentPage else { return }

        let nearestPage = pdfView.page(for: location, nearest: true) ?? currentPage
        let convertedPoint = pdfView.convert(location, to: nearestPage)

        // Erasing
        if InkSettings.sharedInstance.tool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: nearestPage)
            return
        }

        // Drawing
        guard currentAnnotation != nil else { return }

        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)

        // Final annotation
        endAnnotating(for: nearestPage)
    }

    private func beginAnnotating(for page: PDFPage, in location: CGPoint) {
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: page)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
    }

    private func endAnnotating(for page: PDFPage) {
        page.removeAnnotation(currentAnnotation!)
        createFinalAnnotation(path: path!, page: page)
        currentAnnotation = nil
    }

    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = CGFloat(InkSettings.sharedInstance.thickness)

        let annotation = DrawingAnnotation(bounds: page.bounds(for: .mediaBox),
                                           forType: .ink,
                                           withProperties: nil)
        annotation.color = InkSettings.sharedInstance.strokeColor
            .withAlphaComponent(CGFloat(InkSettings.sharedInstance.opacity))
        annotation.border = border
        return annotation
    }

    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }

        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage)
        }

        currentAnnotation?.path = path
        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }

    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) {
        let border = PDFBorder()
        border.lineWidth = CGFloat(InkSettings.sharedInstance.thickness)

        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        let signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        signingPathCentered.moveCenter(toPoint: bounds.center)

        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = InkSettings.sharedInstance.strokeColor
            .withAlphaComponent(CGFloat(InkSettings.sharedInstance.opacity))
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
    }

    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        }
    }

    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
}
