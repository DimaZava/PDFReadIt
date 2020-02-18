//
//  InkSettings.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 14.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettings {

    enum DrawingTool: Int, CaseIterable {
        case eraser = 0
        case pencil = 1
        case pen = 2
        case highlighter = 3

        var width: CGFloat {
            switch self {
            case .pencil:
                return 1
            case .pen:
                return 5
            case .highlighter:
                return 10
            case .eraser:
                return 0
            }
        }

        var alpha: CGFloat {
            switch self {
            case .highlighter:
                return 0.3 //0,5
            case .eraser, .pencil, .pen:
                return 1
            }
        }

        var name: String {
            switch self {
            case .eraser:
                return "Eraser"
            case .pencil:
                return "Pencil"
            case .pen:
                return "Pen"
            case .highlighter:
                return "Highlighter"
            }
        }

        var icon: UIImage? {
            switch self {
            case .eraser:
                return UIImage(named: "pdf_reader_eraser")?.withRenderingMode(.alwaysTemplate)
            case .pencil:
                return UIImage(named: "pdf_reader_pencil")?.withRenderingMode(.alwaysTemplate)
            case .pen:
                return UIImage(named: "pdf_reader_pen")?.withRenderingMode(.alwaysTemplate)
            case .highlighter:
                return UIImage(named: "pdf_reader_highlighter")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }

    static let sharedInstance = InkSettings()

    // MARK: - Variables
    var strokeColor: UIColor
    var fillColor: UIColor?
    var opacity: Float
    var thickness: Float
    var tool: DrawingTool {
        didSet {
            opacity = Float(tool.alpha)
            thickness = Float(tool.width)
        }
    }

    // MARK: - Lifecycle
    private init() {
        strokeColor = .blue
        fillColor = nil
        tool = .pen
        opacity = Float(tool.alpha)
        thickness = Float(tool.width)
    }
}
