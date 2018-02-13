//
//  Vocabularies.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/24/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation

public struct Vocabulary: Codable {
  struct Language: Codable{
    enum Code: String, Codable {
      case english = "en"
      case russian = "ru"
      case spanish = "es"
      case german = "de"
    }
    
    var name: String?
    let code: Code
    var icon: Data?
    
    static var english = Language(name: "English", code: .english)
    static var russian = Language(name: "Russian", code: .russian)
    static var german = Language(name: "German", code: .german)
    static var spanish = Language(name: "Spanish", code: .spanish)
    
    init(code: Code) {
      self.code = code
    }
    init(name: String, code: Code) {
      self.name = name
      self.code = code
    }
  }
  
  let sourceLang: Language
  let translationLang: Language
  
  init(source: Language, translation: Language) {
    self.sourceLang = source
    self.translationLang = translation
  }

  func title() -> String {
    return "\(sourceLang.name!) - \(translationLang.name!)"
  }
  
  static var en_ru_Vocabulary = Vocabulary(sourceLang: .english, translationLang: .russian)
  static var es_en_Vocabulary = Vocabulary(sourceLang: .spanish, translationLang: .english)
  static var ede_en_Vocabulary = Vocabulary(sourceLang: .german, translationLang: .english)
  
  static func databaseName(sourceLang: Language, translationLang: Language) -> String {
    switch (sourceLang.code, translationLang.code) {
    case (.german, .english): return "de_en_dictionary"
    case (.spanish, .english): return "es_en_dictionary"
    case (.english, .russian): return "en_ru_dictionary"
    default:
      return ""
    }
  }
  
  init(sourceLang: Language, translationLang: Language) {
    self.sourceLang = sourceLang
    self.translationLang = translationLang
  }
  
}
