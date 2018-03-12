//
//  SuggestionCollectionViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/24/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "suggestionCell"
  @IBOutlet weak var word: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
  
        word.layer.borderWidth = 1.0
        word.layer.cornerRadius = 8.0
        word.layer.borderColor = UIColor.vocAction.cgColor
//        word.textColor = UIColor.vocInputText //UIColor(0x4f555c)
    }

}
