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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let contents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let documents = contents.compactMap { PDFDocument(url: $0) }

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = PDFReaderViewController.instantiateViewController(with: documents.first!)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }

}
