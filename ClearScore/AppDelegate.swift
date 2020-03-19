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
        let baseURL = URL(string: "https://5lfoiyb0b3.execute-api.us-west-2.amazonaws.com")!
        let endpoints = MockEndpointsImplementation(
            baseURL: baseURL
        )
        let localisations = StaticLocalisationsBuilder()
        let builder = CreditScoreModuleBuilder(
            endpoints: endpoints,
            localisations: localisations.build(),
            session: .shared
        )
        let rootViewController = builder.build()
        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

