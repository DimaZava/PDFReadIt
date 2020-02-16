//
//  InkSettingsExampleCell.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettingsExampleCell: UITableViewCell {

    // MARK: - Outlets

    // MARK: - Lifecycle
    func configure(with settings: InkSettings) {
        layer.sublayers?.first(where: { $0 is CAShapeLayer })?.removeFromSuperlayer()

        let examplePath = UIBezierPath()

        let width = bounds.width
        let height = bounds.height
        examplePath.move(to: CGPoint(x: width * 0.1, y: height * 0.5))
        examplePath.addCurve(to: CGPoint(x: width * 0.9, y: height * 0.5),
                             controlPoint1: CGPoint(x: width * 0.4, y: height * 0.25),
                             controlPoint2: CGPoint(x: width * 0.6, y: height  * 0.75))

        let shapeLayer = CAShapeLayer()

        shapeLayer.path = examplePath.cgPath
        shapeLayer.strokeColor = settings.strokeColor.cgColor
        shapeLayer.fillColor = settings.fillColor?.cgColor
        shapeLayer.opacity = settings.opacity
        shapeLayer.lineWidth = CGFloat(settings.thickness)
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        layer.addSublayer(shapeLayer)
    }
    
}
