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

        let url = Bundle.main.url(forResource: "Sample_1", withExtension: "pdf")
        let document = PDFDocument(url: url!)!

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = PDFReaderViewController.instantiateViewController(with: document)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }

}
