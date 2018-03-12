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
    { get {
      return UIColor(red:0.00, green:0.20, blue:0.38, alpha:1.0) } }

  open class var vocInputPlaceholder: UIColor
    { get {
      //return UIColor(red:0.00, green:0.20, blue:0.38, alpha:0.4)
      return UIColor(red:0.580, green:0.580, blue:0.588, alpha:1.0)
    } }

  open class var vocTranslationText: UIColor
    { get { return UIColor(red:0.18, green:0.27, blue:0.00, alpha:1.0) } }
  
  open class var vocTranslationPlaceholder: UIColor
    { get { return UIColor(red:0.18, green:0.27, blue:0.00, alpha:0.4) } }
  
  open class var vocBackground: UIColor
    { get { return UIColor(0xcfcfcf) } }
  
  open class var vocPlainText: UIColor
    { get { return UIColor.black } }
  
  open class var vocAction: UIColor { get { return UIColor(0xeb6648) } }
  
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
  
  open class var vocSmalTitles: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Bold", size: 26)! } } //34
  
  open class var vocTableCellText: UIFont
    { get { return UIFont(name: "SanFranciscoDisplay-Regular", size: 20)! } } //34

  open class var vocPlainText: UIFont
    { get { return UIFont(name: "SanFranciscoText-Regular", size: 22)! } } //34

  open class var vocPlainBoldText: UIFont
    { get { return UIFont(name: "SanFranciscoText-Bold", size: 22)! } } //34
}




