//
//  FlashCardsViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/17/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit


class FlashCardsViewController: BaseViewController {
  enum ViewState {
    case nothing
    case word
    case translation
  }
  var records = DAO.shared.fetchAllWords()
  var currentRecord: VocRecord?
  var state = ViewState.nothing
  
  @IBOutlet weak var lblNoData: UILabel!
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTranslation: UILabel!
  @IBOutlet weak var btnNext: StagedButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Flash cards"
    lblWord.textColor = UIColor.vocInputText
    lblTranslation.textColor = UIColor.vocTranslationText
    lblWord.font = UIFont.vocTitles
    lblTranslation.font = UIFont.vocTitles

    updateUI()
    next()
  }
  
  func updateUI() {
    switch state {
    case .nothing:
      lblNoData.isHidden = false
      lblWord.isHidden = true
      lblTranslation.isHidden = true
      btnNext.isHidden = true
    case .word:
      lblNoData.isHidden = true
      lblWord.isHidden = false
      lblTranslation.isHidden = true
      btnNext.isHidden = false
      btnNext.setTitle("Translate", for: .normal)
    case .translation:
      lblNoData.isHidden = true
      lblWord.isHidden = false
      lblTranslation.isHidden = false
      btnNext.isHidden = false
      btnNext.setTitle("Next", for: .normal)
    }
  }
  
  @IBAction func next() {
    guard records.count > 0 else {
      state = .nothing
      updateUI()
      return
    }
    updateUI()
    switch state {
    case .nothing:
      state = .word
      next()
    case .word:
      currentRecord = records.last
      lblWord.text = currentRecord?.word.spelling
      lblTranslation.text = currentRecord?.trans.spelling
      state = .translation
    case .translation:
      records.removeLast()
      state = .word
    }
  }
}
