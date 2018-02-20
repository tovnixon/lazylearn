//
//  SRViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/23/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit
import  AVFoundation

class SRViewController: BaseViewController {
  enum ViewState {
    case normal
    case noData
  }
  var state: ViewState = ViewState.noData
  var record: VocRecord?
  var records: [VocRecord] = DAO.shared.recordsToProposeNow()
  var synthesizer = AVSpeechSynthesizer()
  var index: Int = 0
  
  @IBOutlet weak var lblNoData: UILabel!
  @IBOutlet weak var wordsView: UIView!
  @IBOutlet weak var lblWord: UnderlineLabel!
  @IBOutlet weak var lblTrans: UnderlineLabel!
  @IBOutlet weak var lblHowWasIt: UILabel!
  @IBOutlet weak var btnTranslate: UIButton!
  @IBOutlet weak var btnVoice: UIButton!
  @IBOutlet weak var gradeView: UIStackView!
  @IBOutlet weak var cnstrWordTop: NSLayoutConstraint!
  @IBOutlet weak var cnstrTransTop: NSLayoutConstraint!
  @IBOutlet var gradeButtons: [StagedButton]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    synthesizer.delegate = self
    records = records.shuffled()
    getNextCard()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateState()
  }
  
  func updateState() {
    let availableWordsCount = DAO.shared.availableToLearnRecordsCount()
    if availableWordsCount == 0 {
      state = .noData
    } else {
      index = 0
      state = .normal
      records = DAO.shared.recordsToProposeNow().shuffled()
    }
    updateUI()
  }
  
  func updateUI() {
    switch state {
    case .noData:
      lblNoData.isHidden = false
      wordsView.isHidden = true
      btnTranslate.isHidden = true
      gradeView.isHidden = true
    case .normal:
      lblNoData.isHidden = true
      wordsView.isHidden = false
      btnTranslate.isHidden = false
      gradeView.isHidden = true
      getNextCard()
    }
  }
  
  func setupUI() {
    lblNoData.font = UIFont.vocHeaders
    wordsView.layer.cornerRadius = 20.0
    
    btnVoice.isHidden = true
    lblTrans.isHidden = true
    gradeView.isHidden = true
    lblHowWasIt.isHidden = true
    lblHowWasIt.textColor = UIColor.vocPlainText
    lblHowWasIt.font = UIFont.vocHeaders
    lblWord.textColor = UIColor.vocInputText
    lblTrans.textColor = UIColor.vocTranslationText
    lblWord.font = UIFont.vocTitles
    lblTrans.font = UIFont.vocTitles
    
    let colorScheme = [UIColor(0xfc3d39), UIColor.vocInputText, UIColor.vocTranslationText, UIColor(0xd55f1b)]
    var i = 0
    for button in gradeButtons {
      button.titleLabel?.font = UIFont.vocSmalTitles
      button.color = colorScheme[safe: i]!
      i += 1
    }
  }
  
  func getNextCard() {
    if let r = records[safe: index] {
      record = r
      
/*      let fontAndColorMain = (UIFont.vocInputText, UIColor.vocInputText)
      let fontAndColorText = (UIFont.vocTableCellText, UIColor.vocAction)
      let inputPlaceholder = "".byConverting(with:
        [(NSMutableAttributedString(string: record!.trans.spelling), fontAndColorMain),
         (NSMutableAttributedString(string: "(\(record!.vocabulary.translationLang.code.rawValue))") , fontAndColorText)])
      
      lblWord.attributedText = inputPlaceholder
 */
      lblWord.text = record!.trans.spelling
      index += 1
    } else {
      index = 0
      records.removeAll()
      updateState()
    }
  }
  
  @IBAction func translate() {
    btnTranslate.isHidden = true
    btnVoice.isHidden = false
    lblTrans.isHidden = false
    voice()
    if let r = record {
      lblTrans.text = r.word.spelling
    }
  }
  
  @IBAction func voice() {
    if let r = record {
      let utterance = AVSpeechUtterance(string: record!.word.spelling)
      utterance.voice = AVSpeechSynthesisVoice(language: r.vocabulary.sourceLang.code.rawValue)
      utterance.rate = 0.4
      synthesizer.speak(utterance)
    }
  }
  
  @IBAction func grade(sender: UIButton) {
    
    let grade = sender.tag
    let recallGrade = RecallGrade(rawValue: grade)!
    record?.gradeRecallEasyness(grade: recallGrade)
    DAO.shared.update(with: record!)
    
    btnTranslate.isHidden = false
    gradeView.isHidden = true
    lblTrans.isHidden = true
    btnVoice.isHidden = true
    lblHowWasIt.isHidden = true
    getNextCard()
  }
}

extension SRViewController: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    lblHowWasIt.isHidden = false
    gradeView.isHidden = false
  }
}
