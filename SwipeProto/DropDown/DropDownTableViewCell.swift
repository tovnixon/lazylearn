//
//  DropDownTableViewCell.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/17/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {
  @IBOutlet weak var label: UILabel!
  var highlightView: UIView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.label.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 50)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    if (highlighted) {
      highlightView?.removeFromSuperview()
      if let text = label.text {
        let s: NSString = text as NSString
        let rect = s.boundingRect(with: CGSize(width: 999, height: 100), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.label.font], context: nil)
        self.highlightView = UIView(frame: rect)
        highlightView!.backgroundColor = UIColor.init(red: 0.7, green: 0.8, blue: 0.863, alpha: 0.5)
        highlightView!.layer.cornerRadius = 10
        label.addSubview(highlightView!)
      }
    } else {
      highlightView?.removeFromSuperview()
    }
  }
    
}
