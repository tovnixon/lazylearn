//
//  WordSelectionView.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/28/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation
import UserNotifications

public struct Word: Codable {
  var spelling: String = ""
  var partOfSpeech: String = ""
}

public struct VocRecord: Codable, Hashable {
  
  var vocabulary: Vocabulary = Vocabulary.en_ru_Vocabulary
  var word: Word = Word()
  var trans: Word = Word()
  var creationDate = Date()
  var srData: StepRepetitionRecord = StepRepetitionRecord()
  var nextDisplayDate: Date = Date()
  var neverLearned = true
  
  var identifier: Int32 = 1
  
  init() {}
  
  init(r: VocRecordSQL) {
    self.identifier = r.id
    self.word = Word(spelling: r.word, partOfSpeech: r.wordPartOfSpeech)
    self.trans = Word(spelling: r.translation, partOfSpeech: r.translationPartOfSpeech)
    self.creationDate = Date(timeIntervalSince1970: r.creationDate)
    self.nextDisplayDate = Date(timeIntervalSince1970: r.nextDisplayDate)
    self.srData = StepRepetitionRecord(eFactor: r.srEFactor, interval: r.srInterval, repetition: r.srRepetitionCount)
    let sourceLang = Vocabulary.Language(code: Vocabulary.Language.Code(rawValue: r.wordLanguageCode)!)
    let transLang = Vocabulary.Language(code: Vocabulary.Language.Code(rawValue: r.translationLanguageCode)!)
    self.vocabulary = Vocabulary(source: sourceLang, translation: transLang)
    self.neverLearned = r.newerLearned > 0
  }
  
  init(_ word: String, trans: String, vocabulary: Vocabulary) {
    //self.identifier = word + trans + String(describing: creationDate)
    self.word.spelling = word
    self.trans.spelling = trans
    self.vocabulary = vocabulary
  }


  mutating func gradeRecallEasyness(grade: RecallGrade) {
    self.neverLearned = false
    let nextInterval = self.srData.doRepetition(with: grade)
    let nextIntervalMinutes = nextInterval * DAO.shared.repetitionStep.rawValue
    if let next = Calendar.current.date(byAdding: .minute, value: Int(nextIntervalMinutes), to: Date()) {
      nextDisplayDate = next
      print("Set next \(nextDisplayDate) to \(self.word.spelling)")
    } else {
      print("VocRecord grade error, can't get next display date")
      nextDisplayDate = Date()
    }
  }
  
  public func shouldBeProposedNow() -> Bool {
    return Date() >= nextDisplayDate
  }
  
  public var hashValue: Int { get {
    return Int(creationDate.timeIntervalSince1970)
    }
  }
  
  public static func ==(lhs: VocRecord, rhs: VocRecord) -> Bool {
    return lhs.identifier == rhs.identifier
  }

}
