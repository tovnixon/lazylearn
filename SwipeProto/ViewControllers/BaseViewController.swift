//
//  BaseViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/18/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let attrs = [
      NSAttributedStringKey.foregroundColor: UIColor.vocPlainText,
      NSAttributedStringKey.font: UIFont.vocHeaders
    ]
    navigationController?.navigationBar.titleTextAttributes = attrs
    view.backgroundColor = UIColor.vocBackground
  }
}
