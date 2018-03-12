//
//  SQLiteProvider.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/21/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import SQLite3

struct SQLRecord {
  var word: String = ""
  var translation: String = ""
  var meaning: String = ""
  var partOfSpeech: String = ""
  var frequency: Double = -1
}

class SQLiteManager {
  var db: OpaquePointer?
  var dbName: String = "EnRu"
 
  init(name: String) {
    self.dbName = name
  }
  func openDataBase() -> Bool {
    guard let path = Bundle.main.path(forResource: dbName, ofType: "sqlite"), sqlite3_open(path, &db) == SQLITE_OK else {
      print("SQLite failed to open database")
      return false
    }
    return true
  }

  func closeDataBase() -> Bool {
    let result = sqlite3_close(db)
    db = nil
    if result != SQLITE_OK {
      print("failed to close sqlite3 db")
      return false
    }
    return true
  }
  
  func fetchTranslations(for word: String) -> [String] {
    let queryString = "SELECT DISTINCT translation FROM dictionary WHERE word IS '\(word)'"
    var stmp: OpaquePointer?
    if sqlite3_prepare(db, queryString, -1, &stmp, nil) != SQLITE_OK {
      let error = String(cString: sqlite3_errmsg(db)!)
      print("fetch error \(error)")
      return [String]()
    }
    
    var result = [String]()
    while sqlite3_step(stmp) == SQLITE_ROW {
      if let translation = sqlite3_column_text(stmp, 0) {
        let t = String(cString: translation)
        result.append(t)
      }
    }
    if sqlite3_finalize(stmp) != SQLITE_OK {
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("error finalizing prepared statement: \(errmsg)")
    }
    return result
  }
  
  func fetchWords(by text: String) -> [SQLRecord] {
    
    let start = Date()
    
    let queryString = "SELECT * FROM dictionary WHERE word LIKE '\(text)%' and frequency > 0 GROUP BY word ORDER BY frequency ASC"
    var stmp: OpaquePointer?
    if sqlite3_prepare(db, queryString, -1, &stmp, nil) != SQLITE_OK {
      let error = String(cString: sqlite3_errmsg(db)!)
      print("fetch error \(error)")
      return [SQLRecord]()
    }
    var cnt = 0
    var result = [SQLRecord]()
    while sqlite3_step(stmp) == SQLITE_ROW {
      var newRecord = SQLRecord()
      if let word = sqlite3_column_text(stmp, 0) {
        let w = String(cString: word)
        newRecord.word = w
      }
      if let word = sqlite3_column_text(stmp, 1) {
        let w = String(cString: word)
        newRecord.translation = w
      }
      if let word = sqlite3_column_text(stmp, 2) {
        let w = String(cString: word)
        newRecord.meaning = w
      }
      if let word = sqlite3_column_text(stmp, 3) {
        let w = String(cString: word)
        newRecord.partOfSpeech = w
      }
      newRecord.frequency = sqlite3_column_double(stmp, 4)
      
      result.append(newRecord)
      
      cnt += 1
    }
    if sqlite3_finalize(stmp) != SQLITE_OK {
      let errmsg = String(cString: sqlite3_errmsg(db)!)
      print("error finalizing prepared statement: \(errmsg)")
    }
    
    let end = Date()
    stmp = nil
    let diff = end.timeIntervalSince(start)
    print("got \(cnt) records in \(diff)")
    return result
  }
  
}
