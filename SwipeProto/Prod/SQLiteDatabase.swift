//
//  SQLiteDatabase.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/9/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import SQLite3

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public enum SQLiteError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

class SQLiteDatabase {
  let dbPointer: OpaquePointer?
  
  init(dbPointer: OpaquePointer?) {
    self.dbPointer = dbPointer
  }
  
  var errorMessage: String {
    if let errorPointer = sqlite3_errmsg(dbPointer) {
      let errorMessage = String(cString: errorPointer)
      return errorMessage
    } else {
      return "No error message provided from sqlite."
    }
  }
  
  deinit {
    sqlite3_close(dbPointer)
  }
  
  static func open(path: String) throws -> SQLiteDatabase {
    var db: OpaquePointer? = nil
    if sqlite3_open(path, &db) == SQLITE_OK {
      return SQLiteDatabase(dbPointer: db)
    } else {
      defer {
        if db != nil {
          sqlite3_close(db)
        }
      }
      
      if let errorPointer = sqlite3_errmsg(db) {
        let message = String.init(cString: errorPointer)
        throw SQLiteError.OpenDatabase(message: message)
      } else {
        throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
      }
    }
  }
}

extension SQLiteDatabase {
  func prepareStatement(sql: String) throws -> OpaquePointer? {
    var statement: OpaquePointer? = nil
    guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
      throw SQLiteError.Prepare(message: errorMessage)
    }
    return statement
  }
}

extension SQLiteDatabase {
  
  func createRecordsTable() throws {
    let createStatement = """
    CREATE TABLE IF NOT EXISTS `records` (
    `\(VocRecordSQL.Labels.id.rawValue)`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `\(VocRecordSQL.Labels.word.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.wordPartOfSpeech.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.translation.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.translationPartOfSpeech.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.creationDate.rawValue)`  REAL NOT NULL,
    `\(VocRecordSQL.Labels.nextDisplayDate.rawValue)`  REAL,
    `\(VocRecordSQL.Labels.neverLearned.rawValue)`  INTEGER DEFAULT 1,
    `\(VocRecordSQL.Labels.wordLanguageCode.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.translationLanguageCode.rawValue)`  TEXT,
    `\(VocRecordSQL.Labels.srEFactor.rawValue)`  REAL DEFAULT 2.5,
    `\(VocRecordSQL.Labels.srInterval.rawValue)`  INTEGER DEFAULT 0,
    `\(VocRecordSQL.Labels.srRepetitionCount.rawValue)`  INTEGER DEFAULT 0
    );
    """
    let createTableStatement = try prepareStatement(sql: createStatement)
    // 2
    defer {
      sqlite3_finalize(createTableStatement)
    }
    // 3
    guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
      throw SQLiteError.Step(message: errorMessage)
    }
    print("'records' table created.")
  }
  
  func update(record: VocRecordSQL) {
    let assignments = VocRecordSQL.columns().map { label -> String in
      if let bridge = VocRecordSQL.binding[label] {
        var value: String = ""
        switch bridge.columnType {
        case .text: value = record[keyPath: bridge.keyPathString!]
        case .double: value = String(record[keyPath: bridge.keyPathDouble!])
        case .int: value = String(record[keyPath: bridge.keyPathInt!])
        }
        let s = "\(label) = '\(value)'"
        return s
      }
      return "1"
    }
    let query = """
    UPDATE records SET \(assignments.joined(separator: ", ")) WHERE id = \(record.id);
    """
    guard let updateStatement = try? prepareStatement(sql: query) else {
      return
    }
    defer {
      sqlite3_finalize(updateStatement)
    }
    
    guard sqlite3_step(updateStatement) == SQLITE_DONE else {
      return
    }
  }
  
  func allRecords() -> [VocRecordSQL] {
    guard let queryStatement = try? prepareStatement(sql: "SELECT * FROM records") else {
      return [VocRecordSQL]()
    }
    defer {
      sqlite3_finalize(queryStatement)
    }
    var records = [VocRecordSQL]()
    while sqlite3_step(queryStatement) == SQLITE_ROW {
      let r = record(queryStatement)
      records.append(r)
    }
    return records
  }
  
  func vocRecrod(word: String) -> VocRecordSQL? {
    let querySql = "SELECT * FROM records WHERE word = ?;"
    guard let queryStatement = try? prepareStatement(sql: querySql) else {
      return nil
    }
    
    defer {
      sqlite3_finalize(queryStatement)
    }
    guard sqlite3_bind_text(queryStatement, 1, word, -1, nil) == SQLITE_OK else {
      return nil
    }
    guard sqlite3_step(queryStatement) == SQLITE_ROW else {
      return nil
    }
    
    return record(queryStatement)
  }
  
  private func record(_ queryStatement: OpaquePointer?) -> VocRecordSQL {
    var record: VocRecordSQL = VocRecordSQL()
    let mirror = Mirror(reflecting: record)
    for ch in mirror.children {
      if let label = ch.label {
        if let bridge = VocRecordSQL.readBinding()[label] {
          switch bridge.columnType {
          case .text:
            if let queryResult = sqlite3_column_text(queryStatement, bridge.columnNumber) {
              record[keyPath: bridge.keyPathString!] = String(cString: queryResult)
            }
          case .double:
            let queryResult = sqlite3_column_double(queryStatement, bridge.columnNumber)
            record[keyPath: bridge.keyPathDouble!] = queryResult
          case .int:
            let queryResult = sqlite3_column_int(queryStatement, bridge.columnNumber)
            record[keyPath: bridge.keyPathInt!] = queryResult
          }
        }
      }
    }
    return record
  }
  
  func recordsSortedByProposalDate() -> [VocRecordSQL] {
    guard let queryStatement = try? prepareStatement(sql: "SELECT * FROM records WHERE neverLearned = 0 ORDER BY nextDisplayDate ASC") else {
      return [VocRecordSQL]()
    }
    defer {
      sqlite3_finalize(queryStatement)
    }
    var records = [VocRecordSQL]()
    while sqlite3_step(queryStatement) == SQLITE_ROW {
      let r = record(queryStatement)
      records.append(r)
    }
    return records
  }
  
  func availableToLearnRecords() throws -> Int32 {
    var count: Int32 = 0
    let now = Date().timeIntervalSince1970
    let query = "SELECT COUNT (DISTINCT id) FROM records WHERE nextDisplayDate <= \(now);"
    let queryStatement = try prepareStatement(sql: query)
    defer {
      sqlite3_finalize(queryStatement)
    }
    while sqlite3_step(queryStatement) == SQLITE_ROW {
      count = sqlite3_column_int(queryStatement, 0);
    }
    
    return count
  }

  func availableToRepeatRecordsCount() throws -> Int32 {
    var count: Int32 = 0
    let now = Date().timeIntervalSince1970
    let query = "SELECT COUNT (DISTINCT id) FROM records WHERE nextDisplayDate <= \(now) AND neverLearned = 0;"
    let queryStatement = try prepareStatement(sql: query)
    defer {
      sqlite3_finalize(queryStatement)
    }
    while sqlite3_step(queryStatement) == SQLITE_ROW {
      count = sqlite3_column_int(queryStatement, 0);
    }
    
    return count
  }

  
  func insertSQL(record: VocRecordSQL) throws {
    let insertSql = """
    INSERT INTO
    records (\(VocRecordSQL.Labels.allValues.map {$0.rawValue}.joined(separator: ", ")))
    VALUES (\(VocRecordSQL.Labels.allValues.map { _ in "?" }.joined(separator: ", ")));
    """
    
    let insertStatement = try prepareStatement(sql: insertSql)
    defer {
      sqlite3_finalize(insertStatement)
    }
    
    let mirror = Mirror(reflecting: record)
    var sqlResult = SQLITE_OK
    for ch in mirror.children {
      if let label = ch.label {
        if let bridge = VocRecordSQL.binding[label] {
          switch bridge.columnType {
          case .text:
            sqlResult = sqlite3_bind_text(insertStatement, bridge.columnNumber, record[keyPath: bridge.keyPathString!].cString(using: .utf8), -1, SQLITE_TRANSIENT)
          case .double:
            sqlResult = sqlite3_bind_double(insertStatement, bridge.columnNumber, record[keyPath: bridge.keyPathDouble!])
          case .int:
            sqlResult = sqlite3_bind_int(insertStatement, bridge.columnNumber, record[keyPath: bridge.keyPathInt!])
          }
          if SQLITE_OK != sqlResult {
            throw SQLiteError.Bind(message: errorMessage)
          }
        }
      }
    }
    
    guard sqlite3_step(insertStatement) == SQLITE_DONE else {
      throw SQLiteError.Step(message: errorMessage)
    }
    print("Successfully inserted row.")
  }
}

