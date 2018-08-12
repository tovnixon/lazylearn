//
//  AddWordsViewModel.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 3/12/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation

class AddWordsViewModel {
  enum State: NSInteger {
    case inputWord
    case inputTranslation
    case inputConfirm
  }

  // service data
  let dbProvider = SQLiteManager(name: Vocabulary.databaseName(sourceLang: DAO.shared.currentVocabulary.sourceLang, translationLang: DAO.shared.currentVocabulary.translationLang))

  init() {
    _ = dbProvider.openDataBase()
  }
  
  deinit {
    _ = dbProvider.closeDataBase()
  }
  // view model
  var source: String? = "" {
    didSet {
      guard let searchString = source else {
        return
      }
      if searchString.count > 2 {
        fetchSuggestions()
      }
    }
  }
  
  var translation: String? = "" {
    didSet {
      
    }
  }
  
  let suggestionsViewModelsTypes: [CellRepresentable.Type] = [SuggestionCellViewModel.self]
  var suggestionsViewModels = [CellRepresentable]()
  var translationViewModels = [CellRepresentable]()
  
  var state: State = .inputWord
  
  // MARK: out
  var didUpdateInputSuggestions: ((AddWordsViewModel) -> Void)?
  var didSelectInput: ((String) -> Void)?
  var didSelectTranslation: ((String) -> Void)?
  var didUpdateState: ((AddWordsViewModel.State) -> Void)?
  var didAddWord: (() -> Void)?
  
  // MARK: in
  func fetchSuggestions() {
    guard let searchString = source else {
      return
    }
    suggestionsViewModels = dbProvider.fetchWords(by: searchString).map {
      return suggestionFor(sqlRecord: $0)
    }
    didUpdateInputSuggestions?(self)
  }
  
  func fetchTranslations() {
    guard let searchString = source else {
      return
    }
    suggestionsViewModels = dbProvider.fetchTranslations(for: searchString).map {
      return translationFor(string: $0)
    }
    didUpdateInputSuggestions?(self)
  }
  
  func sourceDidEndEditing() {
    if state == .inputWord {
      guard let s = source else { return }
      if s.count > 0 {
        state = .inputTranslation
        didUpdateState?(state)
        self.fetchTranslations()
      }
    }
  }

  func translationDidEndEditing() {
    if state == .inputTranslation {
      guard let s = translation else { return }
      if s.count > 0 {
        state = .inputConfirm
        didUpdateState?(state)
      }
    }
  }

  func sourceBeginEditing() {
    state = .inputWord
  }
  
  func translationBeginEditing() {
    state = .inputTranslation
  }
  
  func next() {
    guard let source = source, let translation = translation, source.count > 0 && translation.count > 0 else {
      
      //use bool: empty/not
      
      return
    }
    let hasSource = Bool(string: source)
    let hasTranslation = Bool(string: translation)
    switch (hasSource, hasTranslation) {
    case (true, true):
      break
    case (true, false):
      break
    case (false, true):
      break
    case (false, false):
      break

    }
    
    let r = VocRecord(source, trans: translation, vocabulary: DAO.shared.currentVocabulary)
    DAO.shared.insert(r)
    self.source = nil
    self.translation = nil
    suggestionsViewModels.removeAll()
    didAddWord?()
    self.didUpdateInputSuggestions?(self)
    state = .inputWord
  }
  
  // MARK: Internal
  private func updateState() {
    switch state {
      case .inputWord:
        
      break
      case .inputTranslation: break
      case .inputConfirm: break
    }
  }
  
  private func suggestionFor(sqlRecord: SQLRecord) -> CellRepresentable {
    var suggestion = SuggestionCellViewModel()
    suggestion.text = sqlRecord.word
    
    suggestion.didSelectSuggestion = { [weak self] string in
      self?.didSelectInput?(string)
      self?.source = string
      self?.sourceDidEndEditing()
    }
    return suggestion
  }
  
  private func translationFor(string: String) -> CellRepresentable {
    var suggestion = SuggestionCellViewModel()
    suggestion.text = string
    
    suggestion.didSelectSuggestion = { [weak self] string in
      self?.didSelectTranslation?(string)
      self?.translation = string
      self?.translationDidEndEditing()
    }
    return suggestion
  }
}
