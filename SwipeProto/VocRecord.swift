//
//  WordSelectionView.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/28/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation
import UserNotifications

struct VocRecord: Codable, Hashable {
  
  var vocabulary: Vocabulary
  var word: String
  var partOfSpeech: String?
  var trans: String
  var creationDate = Date()
  var srData: StepRepetitionRecord = StepRepetitionRecord()
  var nextDisplayDate: Date = Date(timeIntervalSince1970: 0)
  var neverLearned = true
  
  let identifier: String
  
  init(_ word: String, trans: String, vocabulary: Vocabulary) {
    self.identifier = word + trans + String(describing: creationDate)
    self.word = word
    self.trans = trans
    self.vocabulary = vocabulary
  }
  
  mutating func gradeRecallEasyness(grade: RecallGrade) {
    self.neverLearned = false
    let nextInterval = self.srData.doRepetition(with: grade)
    let nextIntervalMinutes = nextInterval * DAO.shared.repetitionStep.rawValue
    if let next = Calendar.current.date(byAdding: .minute, value: nextIntervalMinutes, to: Date()) {
      nextDisplayDate = next
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
  
  static func ==(lhs: VocRecord, rhs: VocRecord) -> Bool {
    return lhs.identifier == rhs.identifier
  }

}
