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

  static func scanWordsAndSchedule() {
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    let records = DAO.shared.recordsSortedByProposalDate()
    var i: Int = 1
    for r in records {
      if !r.neverLearned {
        let content = UNMutableNotificationContent()
        content.badge = i as NSNumber
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
        let components = NSCalendar.current.dateComponents(unitFlags, from: r.nextDisplayDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = r.identifier
        let request = UNNotificationRequest(identifier: String(identifier),
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
          if let error = error {
            print("Error scheduling local notification \(error)")
          }
        })
        i += 1
      }
    }
    UIApplication.shared.applicationIconBadgeNumber = Int(DAO.shared.availableToRepeatRecordsCount())
  }
}
