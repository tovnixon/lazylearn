//
//  UIView+Autolayout.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/16/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit

extension UIView {
  func stickToParent() {
    if let parent = self.superview {
      self.translatesAutoresizingMaskIntoConstraints = false
      let width = NSLayoutConstraint(item: self, attribute: .width,relatedBy: .equal,toItem: parent,
        attribute: .width, multiplier: 1.0, constant: 0)
      let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,toItem: parent, attribute: .height, multiplier: 1.0, constant: 0)

      let top = NSLayoutConstraint (
        item: self,
        attribute: NSLayoutAttribute.top,
        relatedBy: NSLayoutRelation.equal,
        toItem: parent,
        attribute: NSLayoutAttribute.top,
        multiplier: 1.0,
        constant: 0)
      let leading = NSLayoutConstraint (
        item: self,
        attribute: NSLayoutAttribute.leading,
        relatedBy: NSLayoutRelation.equal,
        toItem: parent,
        attribute: NSLayoutAttribute.leading,
        multiplier: 1.0,
        constant: 0)
      
      parent.addConstraints([width,height,top,leading])
    }
  }
  
  /** Loads instance from nib with the same name. */
  func loadNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nibName = type(of: self).description().components(separatedBy: ".").last!
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as! UIView
  }  
}

public extension Collection {
  private func distance(from startIndex: Index) -> IndexDistance {
    return distance(from: startIndex, to: self.endIndex)
  }
  
  private func distance(to endIndex: Index) -> IndexDistance {
    return distance(from: self.startIndex, to: endIndex)
  }
  
  public subscript(safe index: Index) -> Iterator.Element? {
    if distance(to: index) >= 0 && distance(from: index) > 0 {
      return self[index]
    }
    return nil
  }
  
  public subscript(safe bounds: Range<Index>) -> SubSequence? {
    if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) >= 0 {
      return self[bounds]
    }
    return nil
  }
  
  public subscript(safe bounds: ClosedRange<Index>) -> SubSequence? {
    if distance(to: bounds.lowerBound) >= 0 && distance(from: bounds.upperBound) > 0 {
      return self[bounds]
    }
    return nil
  }
}
