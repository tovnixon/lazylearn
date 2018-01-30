//
//  RecordTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTranslation: UILabel!
  //RecordTableViewCellId
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
    
}
