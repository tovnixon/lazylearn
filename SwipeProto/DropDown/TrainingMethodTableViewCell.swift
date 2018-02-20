//
//  TrainingMethodTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/18/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class TrainingMethodTableViewCell: UITableViewCell {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDescription: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    lblTitle.font = UIFont.vocTitles
    lblDescription.font = UIFont.vocTableCellText
    lblTitle.textColor = UIColor.vocAction
    lblDescription.textColor = UIColor.black
    
    // Initialization code
  }
  
  func bind(trainingMethod: TrainingMethod) {
    lblTitle.text = trainingMethod.name
    lblDescription.text = trainingMethod.description
    iconImageView.image = trainingMethod.icon
  }
}
