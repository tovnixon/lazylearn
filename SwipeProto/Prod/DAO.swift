//
//  DAO.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 12/11/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import Foundation

class DAO {
  var records : [VocRecord] = []
  let userDefaultsRecordsKey = "VocRecords"
  let userDefaultsVocabularyKey = "CurrentVocabularyKey"
  
  var currentVocabulary = Vocabulary.en_ru_Vocabulary { didSet {
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
    saveOnDisk()
  }
  
  func fetchAllWords() -> [VocRecord] {
    return records
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
    
  private func saveOnDisk() {
    let encoder = PropertyListEncoder()
    let userDefaults = UserDefaults.standard
    do {
      let data = try encoder.encode(records)
      userDefaults.set(data, forKey: userDefaultsRecordsKey)
      let vocData = try encoder.encode(currentVocabulary)
      userDefaults.set(vocData, forKey: userDefaultsVocabularyKey)
    } catch {
      print(error)
    }
  }
  
  private func readFromDisk() {
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
  }
}
