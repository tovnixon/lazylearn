//
//  WordSelectionView.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/28/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation

struct VocRecord: Codable, Hashable {
  
  var vocabulary: Vocabulary
  var word: String
  var trans: String
  var creationDate = Date()
  var srData: StepRepetitionRecord = StepRepetitionRecord()
  var nextDisplayDate: Date = Date()
  
  let identifier: String
  
  private var displayCounter: Int = 0 // how many times word was showed in training
  private var knowCounter: Int = 0 // how many time word was claimed as known
  private var dontKnowCounter: Int = 0 // how many time the word was claimed as unknown
  private var trainingResults: [Int] = [Int]()
  
  init(_ word: String, trans: String, vocabulary: Vocabulary) {
    self.identifier = word + trans + String(describing: creationDate)
    self.word = word
    self.trans = trans
    self.vocabulary = vocabulary
  }
  
  mutating func gradeRecallEasyness(grade: RecallGrade) {
    let nextInterval = self.srData.doRepetition(with: grade)
    if let next = Calendar.current.date(byAdding: .hour, value: nextInterval, to: Date()) {
      nextDisplayDate = next
    } else {
      print("VocRecord grade error, can't get next display date")
      nextDisplayDate = Date()
    }
  }
  
  public func shouldBeProposedNow() -> Bool {
    return Date() >= nextDisplayDate
   //   return fabs(Date().timeIntervalSince(nextDisplayDate)) <= 24*3600.0
  }
  
  public var hashValue: Int { get {
    return Int(creationDate.timeIntervalSince1970)
    }
  }
  
  static func ==(lhs: VocRecord, rhs: VocRecord) -> Bool {
    return lhs.identifier == rhs.identifier
  }

}
