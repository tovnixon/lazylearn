//
//  TextPickerViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class TextPickerViewController: UIViewController {
  @IBOutlet weak var transSuggestionsView: UICollectionView!
  @IBOutlet weak var cnstrTransSuggestionsViewHeight: NSLayoutConstraint!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var recordsTableView: UITableView!
  @IBOutlet weak var textPicker: TextPickerView!
  
  let dbProvider = SQLiteManager(name: Vocabulary.databaseName(sourceLang: DAO.shared.currentVocabulary.sourceLang, translationLang: DAO.shared.currentVocabulary.translationLang))
  
  var suggestions: [String] = [String]()
  var records: [VocRecord] = [VocRecord]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let nibName = UINib(nibName: "SuggestionCollectionViewCell", bundle: nil)
    transSuggestionsView.register(nibName, forCellWithReuseIdentifier: SuggestionCollectionViewCell.reuseIdentifier)
    let nibName2 = UINib(nibName: "VocRecordTableViewCell", bundle: nil)
    recordsTableView.register(nibName2, forCellReuseIdentifier: VocRecordTableViewCell.reuseIdentifier)

    textPicker.delegate = self
    textPicker.backgroundColor = .clear
    
    var text = """
    Creates a new instance by decoding from the given decoder.
    
    This initializer throws an error if reading from the decoder fails, or
    if the data read is corrupted or otherwise invalid.
    
    - Parameter decoder: The decoder to read data from.
    Encodes this value into the given encoder.
    
    If the value fails to encode anything, `encoder` will encode an empty
    keyed container in its place.
    
    This function throws an error if any values are invalid for the given
    encoder's format.
    
    - Parameter encoder: The encoder to write data to.

    """
    _ = dbProvider.openDataBase()
    let textItems = TextProcessor.process(text: text, vocabulary: DAO.shared.currentVocabulary, db: dbProvider)
    textPicker.textItems = textItems
    self.reloadSuggestions()
  }

}

extension TextPickerViewController: TextPickerViewDelegate {
  func textView(_ textView: TextPickerView, picked text: String) {
    suggestions = dbProvider.fetchTranslations(for: text)
    self.reloadSuggestions()
  }
  func textView(_ textView: TextPickerView, unpicked text: String) {
    suggestions.removeAll()
    self.reloadSuggestions()
  }
}

extension TextPickerViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return records.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellId = VocRecordTableViewCell.reuseIdentifier
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! VocRecordTableViewCell
    if let r = records[safe: indexPath.row] {
      cell.lblWord.text = r.word.spelling
      cell.lblTranslation.text = r.trans.spelling
    }
    return cell
  }
}

extension TextPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = suggestions[safe: indexPath.row],
      let selectedText = textPicker.selectedButton?.displayText else {
      return
    }
    
    let r = VocRecord(selectedText, trans: item, vocabulary: DAO.shared.currentVocabulary)
    if (records.map { $0.word.spelling }.contains(selectedText)) {
      print("Duplication")
      return
    }
    records.insert(r, at: 0)
    recordsTableView.beginUpdates()
    recordsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    recordsTableView.endUpdates()
    textPicker.currentWordWasProcessed()
    // TODO: add part of speech
//    DAO.shared.insert(r)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return suggestions.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellId = SuggestionCollectionViewCell.reuseIdentifier
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SuggestionCollectionViewCell
    
    if let word = suggestions[safe: indexPath.row] {
      cell.word.text = word
      cell.word.textColor = UIColor.vocTranslationText
      if (records.map {$0.trans.spelling}.contains(word)) {
        cell.backgroundColor = .green
      } else {
        cell.backgroundColor = .clear
      }
    }
    //cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
    let cellsCount = suggestions.count
    
    let width = collectionView.bounds.size.width
    let defaultCellHeight = suggestionCellHeight(for: cellsCount)
    var size: CGSize
    let fullSize = CGSize(width: width, height: defaultCellHeight)
    let halfSize = CGSize(width: width * 0.5 - 10, height: defaultCellHeight);
    switch cellsCount {
    case 1: size = fullSize; break
    case 2,4,6: size = halfSize; break
    case 3,5: if indexPath.row == 0 {
      size = fullSize
    } else { size = halfSize}
    default:
      size = halfSize
    }
    return size
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }

  func suggestionCellHeight(for amount: Int) -> CGFloat {
    switch amount {
    case 1...2: return 60
    case 3...4: return 60
    default: return 40
    }
  }
  
  func reloadSuggestions() {
    var h: CGFloat = 0
    defer {
      cnstrTransSuggestionsViewHeight.constant = h
      view.setNeedsDisplay()
      transSuggestionsView.reloadData()
    }

    let count = suggestions.count
    let defaultCellHeight = suggestionCellHeight(for: count)
    h = 3 * defaultCellHeight
    if count == 0 {
      h = 0
    } else if count <= 2 {
      h = defaultCellHeight
    } else if count <= 4 {
      h = 2 * defaultCellHeight
    }
  }


}
