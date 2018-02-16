//
//  SelectTrainingViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/16/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class SelectTrainingViewController: UIViewController {
    override func viewDidLoad() {
      super.viewDidLoad()
      DAO.shared.deleteRecord(by: 90)
    }
}
