//
//  SuggestionCollectionViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/24/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var word: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
  
        word.layer.borderWidth = 2.0
        word.layer.cornerRadius = 8.0
        word.layer.borderColor = UIColor.vocSeparator.cgColor
        
    }

}
