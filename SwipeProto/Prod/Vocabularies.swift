//
//  Vocabularies.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/24/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation


class Vocabulary: Codable {
  
  struct Language: Codable{
    enum Code: String, Codable {
      case english = "en"
      case russian = "ru"
      case spanish = "es"
      case german = "de"
    }
    
    let name: String
    let code: Code
    var icon: Data?
    
    static var english = Language(name: "English", code: .english)
    static var russian = Language(name: "Russian", code: .russian)
    static var german = Language(name: "German", code: .german)
    static var spanish = Language(name: "Spanish", code: .spanish)
    
    init(name: String, code: Code) {
      self.name = name
      self.code = code
    }
  }
  
  let sourceLang: Language
  let translationLang: Language
  var database: String
  
  func title() -> String {
      return "\(sourceLang.name) - \(translationLang.name)"
  }
  
  static var en_ru_Vocabulary = Vocabulary(sourceLang: .english, translationLang: .russian, database: "en_ru_dictionary")
  static var es_en_Vocabulary = Vocabulary(sourceLang: .spanish, translationLang: .english, database: "es_en_dictionary")
  static var ede_en_Vocabulary = Vocabulary(sourceLang: .german, translationLang: .english, database: "de_en_dictionary")
  
  private init(sourceLang: Language, translationLang: Language, database: String) {
    self.sourceLang = sourceLang
    self.translationLang = translationLang
    self.database = database
  }
  
}
