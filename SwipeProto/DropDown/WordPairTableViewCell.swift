//
//  WordPairTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/21/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class WordPairTableViewCell: UITableViewCell {
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTranslation: UILabel!
  @IBOutlet weak var separator: UIView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
