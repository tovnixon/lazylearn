//
//  TabBarViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/31/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // update badge on Memorise section
    Notification.Name.newRecordsAvailable.onPost { [weak self] note in
      guard self != nil, let userInfo = note.userInfo else { return }
      if let cnt = userInfo["count"] as? Int {
        UIApplication.shared.applicationIconBadgeNumber = cnt
        if cnt > 0 {
          self?.tabBar.items![2].badgeValue = String(cnt)
        } else {
          self?.tabBar.items![2].badgeValue = nil
        }
      }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
