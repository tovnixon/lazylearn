//
//  TextProcessor.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation

class TextItem {
  var text: String = ""
  var isTranslatable: Bool = false
  init(_ text: String, isTranslatable: Bool) {
    self.text = text
    self.isTranslatable = isTranslatable
  }
}

class TextProcessor {
  static func process(text: String, vocabulary: Vocabulary, db: SQLiteManager) -> [TextItem] {
    let strings = text.components(separatedBy: " ")
//    let punctuation = CharacterSet(charactersIn: ".,;?!")
    var textItems = [TextItem]()
    for s in strings {
      let translations = db.fetchTranslations(for: s)
      let textItem = TextItem(s, isTranslatable: translations.count > 0)
      textItems.append(textItem)
    }
    return textItems
  }
}
