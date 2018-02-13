//
//  AppDelegate.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 10/21/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let notificationScanner = NotificationScanner()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UINavigationBar.appearance().tintColor = UIColor.vocAction
    UITabBar.appearance().tintColor = UIColor.vocAction
    UITextField.appearance().tintColor = UIColor.vocAction
    UINavigationBar.appearance().barTintColor = UIColor(0xe8e8e9)
    _ = DAO.shared
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    notificationScanner.stop()
    //NotificationScanner.scanWordsAndSchedule()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NotificationScanner.scanWordsAndSchedule()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    notificationScanner.start()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NotificationScanner.scanWordsAndSchedule()
  }


}

