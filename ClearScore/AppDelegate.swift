//
//  AppDelegate.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/18.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootViewController = ViewController()
        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

