//
//  SuggestionViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 3/12/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class SuggestionViewCell: UICollectionViewCell {
  @IBOutlet weak var lblSuggestion: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    lblSuggestion.layer.borderWidth = 1.0
    lblSuggestion.layer.cornerRadius = 8.0
    lblSuggestion.layer.borderColor = UIColor.vocAction.cgColor
    //        word.textColor = UIColor.vocInputText //UIColor(0x4f555c)
  }
  
  func bind(viewModel: SuggestionCellViewModel) {
    lblSuggestion.text = viewModel.text
  }
  
}
