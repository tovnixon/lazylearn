//
//  LocalNotifications.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/31/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
// schedulee notification that new words are available for learning

extension NSNotification.Name {
  static let newRecordsAvailable = Notification.Name("newRecordsAvailable")
  
  func post(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
  }
  
  @discardableResult
  func onPost(object: Any? = nil, queue: OperationQueue? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
    return NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: using)
  }
}

class NotificationScanner {
  var timer: Timer?
  let updateInterval: TimeInterval = 10 // seconds
  
  static func requestAuthorizationForNotifications(completion: @escaping (Bool) -> Swift.Void) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { (authorizationGranted, error) in
        DispatchQueue.main.async {
          completion(authorizationGranted)
        }
      }
    } 
  }
  
  static func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Swift.Void) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        DispatchQueue.main.async {
          completion(settings.authorizationStatus)
        }
      }
    }
  }
  
  func start() {
    self.stop()
    timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(NotificationScanner.checkForNewAvailableWords(timer:)), userInfo: nil, repeats: true)
  }
  
  func stop() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc private func checkForNewAvailableWords(timer: Timer) {
    let availableRecordsCount = DAO.shared.availableToLearnRecordsCount()
    Notification.Name.newRecordsAvailable.post(userInfo: ["count": availableRecordsCount])
  }

  func scanWordsAndSchedule() {
    
  }
}
