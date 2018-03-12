//
//  Extensions.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  convenience init(_ rgb: Int32, alpha: CGFloat) {
    let red = CGFloat((rgb & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgb & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgb & 0xFF)/256.0
    
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
  
  convenience init(_ rgb: Int32) {
    self.init(rgb, alpha:1.0)
  }
}

extension String {
  
  func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    
    return ceil(boundingBox.height)
  }
  
  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    
    return ceil(boundingBox.width)
  }
}

extension UIImage {
  
  public func fixedOrientation() -> UIImage {
    
    if imageOrientation == UIImageOrientation.up {
      return self
    }
    
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    switch imageOrientation {
    case UIImageOrientation.down, UIImageOrientation.downMirrored:
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat.pi)
      break
    case UIImageOrientation.left, UIImageOrientation.leftMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat.pi * 0.5)
      break
    case UIImageOrientation.right, UIImageOrientation.rightMirrored:
      transform = transform.translatedBy(x: 0, y: size.height)
      transform = transform.rotated(by: -0.5 * CGFloat.pi)
      break
    case UIImageOrientation.up, UIImageOrientation.upMirrored:
      break
    }
    
    switch imageOrientation {
    case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
      transform.translatedBy(x: size.width, y: 0)
      transform.scaledBy(x: -1, y: 1)
      break
    case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
      transform.translatedBy(x: size.height, y: 0)
      transform.scaledBy(x: -1, y: 1)
    case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
      break
    }
    
    let ctx: CGContext = CGContext(data: nil,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: self.cgImage!.bitsPerComponent,
                                   bytesPerRow: 0,
                                   space: self.cgImage!.colorSpace!,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    ctx.concatenate(transform)
    
    switch imageOrientation {
    case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      break
    }
    
    let cgImage: CGImage = ctx.makeImage()!
    
    return UIImage(cgImage: cgImage)
  }
}

