//
//  WordPairTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/21/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class VocRecordTableViewCell: UITableViewCell {
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTranslation: UILabel!
  @IBOutlet weak var lblPartOfSpeech: UILabel!
  @IBOutlet weak var btnVolume: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    lblWord.textColor = UIColor.vocInputText
    lblTranslation.textColor = UIColor.vocTranslationText
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

  @IBAction func voice() {
    
  }
}
