//
//  DAO.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 12/11/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation

class DAO {
  var db: SQLiteDatabase?
  private let userDefaultsVocabularyKey = "CurrentVocabularyKey"
  
  var currentVocabulary = Vocabulary.en_ru_Vocabulary
  
  var repetitionStep: RepetitionStep = .day
  
  static let shared = DAO()
  
  init() {
    do {
      try openDB()
      try db?.createRecordsTable()
    } catch {
      print(db?.errorMessage ?? "")
    }

    readFromDisk()
  }
  
  private func openDB() throws {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    let dbPath = documentsDirectory.appendingPathComponent("UserVocabulary.sqlite")
    
    do {
      db = try SQLiteDatabase.open(path: dbPath.absoluteString)
      print("Successfully opened connection to database.")
    } catch SQLiteError.OpenDatabase(let message) {
      print("Error while opening database \(message)")
    }
  }

  func update(with record: VocRecord) {
    db?.update(record: VocRecordSQL(r: record))
  }
  
  func insert(_ record: VocRecord) {
    do {
      let record = VocRecordSQL(r: record)
      try db?.insertSQL(record: record)
    } catch {
      print(db?.errorMessage ?? "")
    }
  }
  
  func fetchAllWords() -> [VocRecord] {
    if let all = db?.allRecords() {
      return all.map {VocRecord(r: $0) }
    }
    return [VocRecord]()
  }
  
  func recordsSortedByProposalDate() -> [VocRecord] {
    if let all = db?.recordsSortedByProposalDate() {
      return all.map {VocRecord(r: $0) }
    }
    return [VocRecord]()
  }

  func recordsSortedByCreationDate() -> [VocRecord] {
    if let all = db?.recordsSortedByCreationDate() {
      return all.map {VocRecord(r: $0) }
    }
    return [VocRecord]()
  }

  func recordsToProposeNow() -> [VocRecord] {
    if let all = db?.recordsToProposeNow() {
      return all.map {VocRecord(r: $0) }
    }
    return [VocRecord]()
  }

  func deleteRecord(by id: Int32) {
    do {
      try db?.delete(by: id)
    } catch {
      
    }
  }
  
  func availableToLearnRecordsCount() -> Int32 {
    do {
      if let c = try db?.availableToLearnRecords() {
        return c
      }
    } catch {
      
    }
    return 0
  }
  
  func availableToRepeatRecordsCount() -> Int32 {
    do {
      if let c = try db?.availableToRepeatRecordsCount() {
        return c
      }
    } catch {
      
    }
    return 0
  }

    
   func saveOnDisk() {
    let encoder = PropertyListEncoder()
    let userDefaults = UserDefaults.standard
    do {
      let vocData = try encoder.encode(currentVocabulary)
      userDefaults.set(vocData, forKey: userDefaultsVocabularyKey)
      
    } catch {
      print(error)
    }
  }
  
  private func readFromDisk() {
    //read repetitin step
    
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

  }
}
