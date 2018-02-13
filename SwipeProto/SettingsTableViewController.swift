//
//  SettingsTableViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/24/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit
//import UserNotifications

class SettingsTableViewController: UITableViewController {

  @IBOutlet weak var repetitionStep: UISegmentedControl!
  @IBOutlet weak var notificationsEnabled: UISwitch!
  @IBOutlet weak var notificationsSection: UITableViewCell!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let attrs = [
      NSAttributedStringKey.foregroundColor: UIColor.vocPlainText,
      NSAttributedStringKey.font: UIFont.vocHeaders
    ]
    navigationController?.navigationBar.titleTextAttributes = attrs
    //repetitionStep.selectedSegmentIndex = DAO.shared.repetitionStep.index()
    notificationsSection.contentView.backgroundColor = UIColor.vocBackground
    tableView.backgroundColor = UIColor.vocBackground
  }
  
  override func viewWillLayoutSubviews() {
    NotificationScanner.getAuthorizationStatus { [weak self] (status) in
      switch status {
      case .authorized:
        self?.notificationsSection.isHidden = true
      case .denied, .notDetermined:
        self?.notificationsSection.isHidden = false
      }
    }
  }
  
  @IBAction func repetitionStepChanged() {
    DAO.shared.repetitionStep = RepetitionStep(index: self.repetitionStep.selectedSegmentIndex)
    DAO.shared.saveOnDisk()
  }
  
  @IBAction func enableNotifications() {
    NotificationScanner.getAuthorizationStatus { [unowned self] (status) in
      if status == .notDetermined {
        NotificationScanner.requestAuthorizationForNotifications(completion: { (enabled) in
          self.notificationsSection.isHidden = enabled
        })
      } else if status == .denied {
        let alert = UIAlertController(title: "Enable notifications", message: "Do you want to be directed to Settings?", preferredStyle: .alert)
        let go = UIAlertAction(title: "Yes", style: .default) { (action) in
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:"App-prefs:root=NOTIFICATIONS_ID&path=com.tovnixon.SwipeProto")! as URL)
          }
        }
        let cancel = UIAlertAction(title: "No", style: .cancel) { (action) in
        }
        alert.addAction(go)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
}
