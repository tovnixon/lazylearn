//
//  TextPickerView.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//
import UIKit

let lineHeight: CGFloat = 32
let wordHeight: CGFloat = 20
let defaultFont = UIFont.vocPlainText

protocol WordButtonDelegate: class {
  func wordButtonTap(_ button: WordButton)
}

class WordButton: Equatable {
  enum ViewState: Int {
    case normal = 0
    case selected = 1
  }
  private let identifier: Int
  private var font: UIFont = UIFont.vocPlainText {
    didSet {
      let width = text.width(withConstrainedHeight: lineHeight, font: font)
      self.size = CGSize(width: width, height: wordHeight)
      button.titleLabel?.font = self.font
    }
  }
  fileprivate var text: String = ""
  var displayText: String {
    return self.text
  }
  var isProcessable: Bool = true {
    didSet {
      button.setTitleColor(isProcessable ? UIColor.black : UIColor.lightGray, for: .normal)
    }
  }
  var isProcessed = false {
    didSet {
      self.font = isProcessed ? UIFont.vocPlainBoldText : UIFont.vocPlainText
    }
  }
  var viewState = ViewState.normal {
    didSet {
      switch viewState {
      case .normal: button.backgroundColor = normalColor
      case .selected: button.backgroundColor = selectedColor
      }
    }
  }
  
  var button = UIButton()
  var normalColor = UIColor.clear
  var selectedColor = UIColor(0x61D836, alpha: 0.1)
  fileprivate var size: CGSize
  weak var delegate: WordButtonDelegate?
  
  init(_ text: String, identifier: Int) {
    self.identifier = identifier
    self.text = text
    let width = text.width(withConstrainedHeight: lineHeight, font: defaultFont)
    self.size = CGSize(width: width, height: wordHeight)
    button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    button.setTitle(self.text, for: .normal)
    button.titleLabel?.font = defaultFont
    button.setTitleColor(UIColor.black, for: .normal)
    button.layer.cornerRadius = 6.0
    button.backgroundColor = normalColor
    button.addTarget(self, action: #selector(WordButton.tapAction), for: .touchUpInside)
  }
  
  @objc func tapAction() {
    if isProcessable {
      viewState = ViewState(rawValue: 1 - viewState.rawValue)!
      delegate?.wordButtonTap(self)
    }
  }
  
  public static func ==(lhs: WordButton, rhs: WordButton) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

protocol TextPickerViewDelegate: class {
  func textView(_ textView: TextPickerView, picked text: String)
  func textView(_ textView: TextPickerView, unpicked text: String)
}

class TextPickerView: UIView, WordButtonDelegate {
  var font: UIFont = UIFont()
  @IBOutlet weak var cnstrHeight: NSLayoutConstraint!
  var selectedButton: WordButton?
  
  weak var delegate: TextPickerViewDelegate?
  
  var textItems = [TextItem]() {
    didSet {
      words.removeAll()
      for i in 0..<textItems.count {
        let textItem = textItems[i]
        let wordButton = WordButton(textItem.text, identifier: i)
        wordButton.delegate = self
        wordButton.isProcessable = textItem.isTranslatable
        words.append(wordButton)
      }
      updateHeight()
      self.setNeedsDisplay()

    }
  }
  
  private var words: [WordButton] = [WordButton]()
  let spaceSize: CGFloat = 6.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  private func configure() {
    
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let myRect = rect//.insetBy(dx: 10, dy: 10)
    var cursorPos = myRect.origin
    cursorPos.x += 10.0
    // draw words one by one
    for word in words {
      if cursorPos.x + word.size.width + spaceSize < myRect.size.width - 10.0 {
        // fill the line
        word.button.frame = CGRect(origin: cursorPos, size: word.size)
        self.addSubview(word.button)
        cursorPos.x += word.size.width + spaceSize
      } else {
        // new line
        cursorPos.y += lineHeight
        cursorPos.x = myRect.origin.x + 10.0
        word.button.frame = CGRect(origin: cursorPos, size: word.size)
        self.addSubview(word.button)
        cursorPos.x += word.size.width + spaceSize
      }
    }
  }
  
  private func updateHeight() {
    let myRect = self.bounds
    var cursorPos = myRect.origin
    cursorPos.x += 10.0
    // draw words one by one
    var totalHeight: CGFloat = 0
    for word in words {
      if cursorPos.x + word.size.width + spaceSize < myRect.size.width - 10.0 {
        // fill the line
        cursorPos.x += word.size.width + spaceSize
        if totalHeight == 0 {
          totalHeight = lineHeight
        }
      } else {
        // new line
        cursorPos.y += lineHeight
        cursorPos.x = myRect.origin.x + 10.0
        cursorPos.x += word.size.width + spaceSize
        totalHeight += lineHeight
      }
    }
    self.cnstrHeight.constant = totalHeight
  }
  
  internal func wordButtonTap(_ button: WordButton) {
    selectedButton = button
    switch button.viewState {
    case .selected:
      delegate?.textView(self, picked: button.text)
    case .normal:
      delegate?.textView(self, unpicked: button.text)
    }
    for word in words {
      if word != button {
        word.viewState = .normal
      }
    }
  }
  
  public func currentWordWasProcessed() {
    selectedButton?.isProcessed = true
    _ = words.map { if $0.text == selectedButton?.text { $0.isProcessed = true } }
    self.setNeedsDisplay()
  }
}
