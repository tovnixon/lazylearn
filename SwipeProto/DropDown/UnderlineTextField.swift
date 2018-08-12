//
//  UnderlineTextField.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/19/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

class StagedButton: UIButton {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.cornerRadius = 10.0
    backgroundColor = .clear
    layer.borderWidth = 2.0
    layer.borderColor = UIColor.vocAction.cgColor
    setTitleColor(UIColor.vocAction, for: .normal)
    titleLabel?.font = UIFont.vocInputText
  }
  
  var color: UIColor = UIColor.blue {
    didSet {
      layer.borderColor = color.cgColor
      setTitleColor(color, for: .normal)
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        layer.borderColor = UIColor.vocAction.cgColor
        setTitleColor(UIColor.vocAction, for: .normal)
      } else {
        layer.borderColor = UIColor.vocInputPlaceholder.cgColor
        setTitleColor(UIColor.vocInputPlaceholder, for: .normal)
      }
    }
  }
}

class UnderlineLabel: UILabel {
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
    let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
    
    let path = UIBezierPath()
    
    path.move(to: startingPoint)
    path.addLine(to: endingPoint)
    path.lineWidth = 1.0
    
    self.textColor.setStroke()
    path.stroke()
  }
}

protocol BackspaceNotificator {
  func backspacePressed(on sender: UITextField)
}

class UnderlineTextField: UITextField {
  var backspaceDelegate: BackspaceNotificator?
  
  public var forceLanguageCode = ""
  
  public var solidUnderline: Bool = false {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  override var textInputMode: UITextInputMode? {
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
  
  override func deleteBackward() {
    super.deleteBackward()
    backspaceDelegate?.backspacePressed(on: self)
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
    let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
    
    let path = UIBezierPath()
    
    path.move(to: startingPoint)
    path.addLine(to: endingPoint)
    path.lineWidth = 1.0
    
    UIColor.vocInputPlaceholder.setStroke()
    if !solidUnderline {
      let pattern: [CGFloat] = [16.0, 8.0]
      path.setLineDash(pattern, count: 2, phase: 0)
    }
    path.stroke()
  }
}

extension String {
  func byConverting(with attributedFormat: [(NSMutableAttributedString, (UIFont, UIColor))]) -> NSMutableAttributedString {
    let fullString = NSMutableAttributedString()
    for (text, (font, color)) in attributedFormat {
      let range = NSRange(location: self.count, length: text.length)
      text.addAttribute(NSAttributedStringKey.font, value: font, range: range)
      text.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
      fullString.append(text)
    }
    return fullString
  }
}
