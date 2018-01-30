//
//  SRViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/23/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit
import  AVFoundation

class SRViewController: UIViewController {
  enum ViewState {
    case normal
    case noData
  }
  var state: ViewState = ViewState.noData
  var record: VocRecord?
  var records: [VocRecord] = [VocRecord]()
  var synthesizer = AVSpeechSynthesizer()
  var index: Int = 0
  
  @IBOutlet weak var lblNoData: UILabel!
  
  @IBOutlet weak var wordsView: UIView!
  @IBOutlet weak var lblWord: UILabel!
  @IBOutlet weak var lblTrans: UILabel!
  @IBOutlet weak var lblHowWasIt: UILabel!
  @IBOutlet weak var btnTranslate: UIButton!
  @IBOutlet weak var btnVoice: UIButton!
  @IBOutlet weak var gradeView: UIStackView!
  @IBOutlet weak var cnstrWordTop: NSLayoutConstraint!
  @IBOutlet weak var cnstrTransTop: NSLayoutConstraint!
  @IBOutlet var gradeButtons: [UIButton]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    synthesizer.delegate = self
    records = DAO.shared.fetchAllWords()
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
      state = .normal
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
    view.backgroundColor = UIColor.lightGray
    wordsView.layer.cornerRadius = 20.0
    btnTranslate.layer.cornerRadius = 10.0
    btnTranslate.backgroundColor = UIColor.vocAction
    btnTranslate.setTitleColor(.white, for: .normal)
    btnVoice.isHidden = true
    lblTrans.isHidden = true
    gradeView.isHidden = true
    lblHowWasIt.isHidden = true
    lblWord.textColor = UIColor.vocInputText
    lblTrans.textColor = UIColor.vocTranslationText
    lblWord.font = UIFont.vocTitles
    lblTrans.font = UIFont.vocTitles
    
    let colorScheme = [UIColor.init(red: 0.067, green: 0.467, blue: 0.722, alpha: 1.0),
                       UIColor.init(red: 0.110, green: 0.643, blue: 0.988, alpha: 1.0),
                       UIColor.init(red: 0.361, green: 0.371, blue: 0.988, alpha: 1.0),
//                       UIColor.init(red: 0.969, green: 0.725, blue: 0.169, alpha: 1.0),
                       UIColor.init(red: 0.992, green: 0.576, blue: 0.149, alpha: 1.0)]
    
    var i = 0
    for button in gradeButtons {
      button.layer.cornerRadius = 6.0
      button.setTitleColor(.white, for: .normal)
      button.titleLabel?.font = UIFont.vocHeaders
      button.backgroundColor = colorScheme[safe: i]
      i += 1
    }
  }
  
  func getNextCard() {
    if let r = records[safe: index] {
      if r.shouldBeProposedNow() && r.trans.count > 0 && r.word.count > 0 {
        record = r
        lblWord.text = record!.trans
      } else {
        index += 1
        getNextCard()
      }
    } else {
      index = 0
      records = DAO.shared.fetchAllWords()
      updateState()
    }
    
  }
  
  @IBAction func translate() {
    btnTranslate.isHidden = true
    btnVoice.isHidden = false
    lblTrans.isHidden = false
    voice()
    if let r = record {
      lblTrans.text = r.word
    }
  }
  
  @IBAction func voice() {
    if let r = record {
      let utterance = AVSpeechUtterance(string: record!.word)
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
    
    index += 1
    
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
