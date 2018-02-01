//
//  ProtoStyle.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/24/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  open class var vocInputText: UIColor
    { get { return UIColor(red:0.00, green:0.20, blue:0.38, alpha:1.0) } }

  open class var vocInputPlaceholder: UIColor
    { get { return UIColor(red:0.00, green:0.20, blue:0.38, alpha:0.4) } }

  open class var vocTranslationText: UIColor
    { get { return UIColor(red:0.18, green:0.27, blue:0.00, alpha:1.0) } }
  
  open class var vocTranslationPlaceholder: UIColor
    { get { return UIColor(red:0.18, green:0.27, blue:0.00, alpha:0.4) } }
  
  open class var vocBackground: UIColor
    { get { return UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0) } }
  
  open class var vocAction: UIColor
    { get { return UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0) } }
  
  open class var vocSeparator: UIColor
    { get { return UIColor(red:0.86, green:0.58, blue:0.00, alpha:1.0) } }
}

extension UIFont {
  open class var vocInputText: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Bold", size: 40)! } } //50
  
  open class var vocTitles: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Bold", size: 30)! } } //40
  
  open class var vocActions: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Bold", size: 30)! } } //40
  
  open class var vocHeaders: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Regular", size: 26)! } } //34
}


