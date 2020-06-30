//
//  AppDelegate.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import PDFKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            let url = Bundle.main.url(forResource: "Sample_1", withExtension: "pdf")
            let docsURL = try FileManager.default.url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false)
            let destinationURL = docsURL.appendingPathComponent("Sample_1.pdf")
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.copyItem(at: url!, to: destinationURL)
            }
            let document = PDFDocument(url: destinationURL)!
            window = UIWindow(frame: UIScreen.main.bounds)
            let viewController = PDFReaderViewController.instantiateViewController(with: document)
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        } catch {
        }

        return true
    }

}
