//
//  AppDelegate.swift
//  Aimer
//
//  Created by Theresa on 2018/7/12.
//  Copyright © 2018年 Carolar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = VideoProcessingViewController()
        window?.makeKeyAndVisible()
        
        return true
    }


}

