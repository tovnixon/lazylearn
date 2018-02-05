//
//  DAO.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 12/11/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation

enum RepetitionStep: Int {
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

class DAO {
  var records : [VocRecord] = []
  private let userDefaultsRecordsKey = "VocRecords"
  private let userDefaultsVocabularyKey = "CurrentVocabularyKey"
  private let userDefaultsRepetitionStepKey = "RepetitionStepKey"
  
  var currentVocabulary = Vocabulary.en_ru_Vocabulary { didSet {
      self.saveOnDisk()
    }
  }
  
  var repetitionStep: RepetitionStep = .tenMin { didSet {
    self.saveOnDisk()
    }
  }
  
  static let shared = DAO()
  
  init() {
    readFromDisk()
  }
  
  func update(with record: VocRecord) {
    if let index = records.index(of: record) {
      records[index] = record
      saveOnDisk()
    } else {
      insert(record)
    }
  }
  
  func insert(_ record: VocRecord) {
    records.append(record)
    // propose to enable notifications
    saveOnDisk()
    if records.count == 10 {
      NotificationScanner.requestAuthorizationForNotifications { (enabled) in
      }
    }
  }
  
  func fetchAllWords() -> [VocRecord] {
    return records
  }
  
  func recordsSortedByProposalDate() -> [VocRecord] {
    let sorted = records.sorted(by: { $0.nextDisplayDate.compare($1.nextDisplayDate) == .orderedAscending } )
    return sorted
  }
  
  func availableToLearnRecordsCount() -> Int {
    var count = 0
    for r in records {
      if r.shouldBeProposedNow() {
        count += 1
      }
    }
    return count
  }
  
  func availableToRepeatRecordsCount() -> Int {
    var count = 0
    for r in records {
      if r.shouldBeProposedNow() && !r.neverLearned {
        count += 1
      }
    }
    return count
  }

    
  private func saveOnDisk() {
    let encoder = PropertyListEncoder()
    let userDefaults = UserDefaults.standard
    do {
      let data = try encoder.encode(records)
      userDefaults.set(data, forKey: userDefaultsRecordsKey)
      let vocData = try encoder.encode(currentVocabulary)
      userDefaults.set(vocData, forKey: userDefaultsVocabularyKey)
      
      userDefaults.set(repetitionStep.rawValue, forKey: userDefaultsRepetitionStepKey)
    } catch {
      print(error)
    }
  }
  
  private func readFromDisk() {
    //read repetitin step
    
    // read records
    if let data = UserDefaults.standard.value(forKey: userDefaultsRecordsKey) as? Data {
      let decoder = PropertyListDecoder()
      do {
        self.records = try decoder.decode(Array<VocRecord>.self, from: data)
      } catch DecodingError.keyNotFound {
        self.records = [VocRecord]()
      } catch {
        self.records = [VocRecord]()
      }
    }
    // read current vocabulary
    if let data = UserDefaults.standard.value(forKey: userDefaultsVocabularyKey) as? Data {
      let decoder = PropertyListDecoder()
      do {
        self.currentVocabulary = try decoder.decode(Vocabulary.self, from:data)
      } catch DecodingError.keyNotFound {
        self.currentVocabulary = Vocabulary.en_ru_Vocabulary
      } catch {
        self.currentVocabulary = Vocabulary.en_ru_Vocabulary
      }
    }
    if let step = UserDefaults.standard.value(forKey: userDefaultsRepetitionStepKey) as? Int {
      self.repetitionStep = RepetitionStep(rawValue: step)!
    }

  }
}
