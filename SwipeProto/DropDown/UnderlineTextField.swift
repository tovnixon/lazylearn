//
//  UnderlineTextField.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/19/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit
class UnderlineTextField: UITextField {
  public var forceLanguageCode = ""
  public var solidUnderline: Bool = false {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  override var textInputMode: UITextInputMode? {
    //let language = type.get
    if forceLanguageCode == "" {
      return super.textInputMode
    }
    for tim in UITextInputMode.activeInputModes {
      if tim.primaryLanguage!.contains(forceLanguageCode) {
        return tim
      }
    }
    return super.textInputMode
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
    let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
    
    let path = UIBezierPath()
    
    path.move(to: startingPoint)
    path.addLine(to: endingPoint)
    path.lineWidth = 4.0
    
    UIColor.vocSeparator.setStroke()
    if !solidUnderline {
      let pattern: [CGFloat] = [16.0, 8.0]
      path.setLineDash(pattern, count: 2, phase: 0)
    }
    path.stroke()
    
  }
}
