//
//  Model.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/9/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation

public enum SQLColumnType {
  case text
  case double
  case int
}

protocol SQLRecordProtocol {
  static func columns() -> [String]
}

struct VocRecordSQL: SQLRecordProtocol {
  enum Labels: String {
    case id = "id"
    case word = "word"
    case wordPartOfSpeech = "wordPartOfSpeech"
    case translation = "translation"
    case translationPartOfSpeech = "translationPartOfSpeech"
    case creationDate = "creationDate"
    case nextDisplayDate = "nextDisplayDate"
    case neverLearned = "neverLearned"
    case wordLanguageCode = "wordLanguageCode"
    case translationLanguageCode = "translationLanguageCode"
    case srEFactor = "srEFactor"
    case srInterval = "srInterval"
    case srRepetitionCount = "srRepetitionCount"
    
    static let allValues = [word, wordPartOfSpeech, translation, translationPartOfSpeech, creationDate, nextDisplayDate, neverLearned, wordLanguageCode, translationLanguageCode, srEFactor, srInterval, srRepetitionCount]
  }
  
  static func columns() -> [String] {
    return Labels.allValues.map {$0.rawValue}
  }
  
  var id: Int32 = 0
  var word: String = ""
  var wordPartOfSpeech: String = ""
  var translation: String = ""
  var translationPartOfSpeech: String = ""
  var creationDate: Double = 0.0
  var nextDisplayDate: Double = 0.0
  var newerLearned: Int32 = 1
  var wordLanguageCode: String = ""
  var translationLanguageCode: String = ""
  var srEFactor: Double = 2.5
  var srInterval: Int32 = 0
  var srRepetitionCount: Int32 = 0
  
  init() {
    
  }
  
  init(r: VocRecord) {
    self.id = r.identifier
    self.word = r.word.spelling
    self.wordPartOfSpeech = r.word.partOfSpeech
    self.translation = r.trans.spelling
    self.translationPartOfSpeech = r.trans.partOfSpeech
    self.creationDate = r.creationDate.timeIntervalSince1970
    self.nextDisplayDate = r.nextDisplayDate.timeIntervalSince1970
    self.newerLearned = r.neverLearned ? 1 : 0
    self.wordLanguageCode = r.vocabulary.sourceLang.code.rawValue
    self.translationLanguageCode = r.vocabulary.translationLang.code.rawValue
    self.srEFactor = r.srData.eFactor
    self.srInterval = r.srData.interval
    self.srRepetitionCount = r.srData.repetition
  }
  
  static var binding: Dictionary<String, SQLBridge> = [
    columns()[0]: SQLBridge(columnNumber: 1, type: .text, keyPathString: \VocRecordSQL.word),
    columns()[1]: SQLBridge(columnNumber: 2, type: .text, keyPathString: \VocRecordSQL.wordPartOfSpeech),
    columns()[2]: SQLBridge(columnNumber: 3, type: .text, keyPathString: \VocRecordSQL.translation),
    columns()[3]: SQLBridge(columnNumber: 4, type: .text, keyPathString: \VocRecordSQL.translationPartOfSpeech),
    columns()[4]: SQLBridge(columnNumber: 5, type: .double, keyPathDouble: \VocRecordSQL.creationDate),
    columns()[5]: SQLBridge(columnNumber: 6, type: .double, keyPathDouble: \VocRecordSQL.nextDisplayDate),
    columns()[6]: SQLBridge(columnNumber: 7, type: .int, keyPathInt: \VocRecordSQL.newerLearned),
    columns()[7]: SQLBridge(columnNumber: 8, type: .text, keyPathString: \VocRecordSQL.wordLanguageCode),
    columns()[8]: SQLBridge(columnNumber: 9, type: .text, keyPathString: \VocRecordSQL.translationLanguageCode),
    columns()[9]: SQLBridge(columnNumber: 10, type: .double, keyPathDouble: \VocRecordSQL.srEFactor),
    columns()[10]: SQLBridge(columnNumber: 11, type: .int, keyPathInt: \VocRecordSQL.srInterval),
    columns()[11]: SQLBridge(columnNumber: 12, type: .int, keyPathInt: \VocRecordSQL.srRepetitionCount)
  ]
  
  static func readBinding() -> Dictionary<String, SQLBridge> {
    var dict = VocRecordSQL.binding
    dict[Labels.id.rawValue] = SQLBridge(columnNumber: 0, type: .int, keyPathInt: \VocRecordSQL.id)
    return dict
  }
}

public enum RepetitionStep: Int32 {
  case tenMin = 10
  case halfHour = 30
  case twelweHours = 720
  case day = 1440
  
  func index() -> Int {
    switch self {
    case .tenMin: return 0
    case .halfHour: return 1
    case .twelweHours: return 2
    case .day: return 3
    }
  }
  
  init(index: Int) {
    switch index {
    case 0: self = .tenMin
    case 1: self = .halfHour
    case 2: self = .twelweHours
    case 3: self = .day
    default: self = .day
    }
  }
}

struct SQLBridge {
  var columnNumber: Int32
  var columnType: SQLColumnType
  var keyPathString: WritableKeyPath<VocRecordSQL, String>?
  var keyPathInt: WritableKeyPath<VocRecordSQL, Int32>?
  var keyPathDouble: WritableKeyPath<VocRecordSQL, Double>?
  
  init(columnNumber: Int32, type: SQLColumnType, keyPathString: WritableKeyPath<VocRecordSQL, String>) {
    self.init(columnNumber: columnNumber, type: type)
    self.keyPathString = keyPathString
  }
  
  init(columnNumber: Int32, type: SQLColumnType, keyPathInt: WritableKeyPath<VocRecordSQL, Int32>) {
    self.init(columnNumber: columnNumber, type: type)
    self.keyPathInt = keyPathInt
  }
  
  init(columnNumber: Int32, type: SQLColumnType, keyPathDouble: WritableKeyPath<VocRecordSQL, Double>) {
    self.init(columnNumber: columnNumber, type: type)
    self.keyPathDouble = keyPathDouble
  }
  
  init(columnNumber: Int32, type: SQLColumnType) {
    self.columnNumber = columnNumber
    self.columnType = type
  }
}

