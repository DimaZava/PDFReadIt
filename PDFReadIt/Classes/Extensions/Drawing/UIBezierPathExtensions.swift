//
//  UIBezierPath+.swift
//  RUDNDocs
//
//  Created by Tim on 24/08/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint( x: size.width / 2.0, y: size.height / 2.0)
    }
}
extension CGPoint {
    func vector(to point: CGPoint) -> CGVector {
        return CGVector(dx: point.x - self.x, dy: point.y - self.y)
    }
}

extension UIBezierPath {

    @discardableResult
    func moveCenter(toPoint: CGPoint) -> Self {
        let bound  = self.cgPath.boundingBox
        let center = bounds.center

        let zeroedTo = CGPoint(x: toPoint.x - bound.origin.x, y: toPoint.y - bound.origin.y)
        let vector = center.vector(to: zeroedTo)

        offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }

    @discardableResult
    func offset(to offset: CGSize) -> Self {
        let transform = CGAffineTransform(translationX: offset.width, y: offset.height)
        applyCentered(transform: transform)
        return self
    }

    @discardableResult
    func fit(into: CGRect) -> Self {
        let bounds = cgPath.boundingBox
        let scaleWidth = into.size.width / bounds.width
        let scaleHeight = into.size.height / bounds.height
        let factor = min(scaleWidth, max(scaleHeight, 0.0))
        return scale(scaleX: factor, scaleY: factor)
    }

    @discardableResult
    func scale(scaleX: CGFloat, scaleY: CGFloat) -> Self {
        let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
        applyCentered(transform: scale)
        return self
    }

    @discardableResult
    func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self {
        let bound  = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform  = CGAffineTransform.identity

        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating( CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)

        return self
    }
}
