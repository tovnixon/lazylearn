//
//  WordPairTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/21/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

protocol VocRecordTableViewCellDelegate: class {
  func pronounce(text: String?)
}

class VocRecordTableViewCell: UITableViewCell {
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTranslation: UILabel!
  @IBOutlet weak var lblPartOfSpeech: UILabel!
  @IBOutlet weak var lblNextDisplay: UILabel!
  @IBOutlet weak var btnVolume: UIButton!
  weak var delegate: VocRecordTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    lblWord.textColor = UIColor.vocInputText
    lblTranslation.textColor = UIColor.vocTranslationText
    lblWord.font = UIFont.vocTableCellText
    lblTranslation.font = UIFont.vocTableCellText
    lblPartOfSpeech.textColor = UIColor.vocPlainText
    lblNextDisplay.textColor = UIColor.vocPlainText
    contentView.backgroundColor = UIColor.vocBackground
    self.backgroundColor = UIColor.vocBackground
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

  @IBAction func voice() {
    delegate?.pronounce(text: lblWord.text)
  }
}
