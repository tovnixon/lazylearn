//
//  TrainigMethod.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/18/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import UIKit

struct TrainingMethod {
  let name: String
  let description: String
  let icon: UIImage
  var numberOfRecords: Int = 0
  
  init(name: String, description: String, icon: UIImage) {
    self.name = name
    self.description = description
    self.icon = icon
  }
}
