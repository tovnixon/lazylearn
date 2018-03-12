//
//  RecordsViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit
import AVFoundation

class RecordsViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  let searchController = UISearchController(searchResultsController: nil)
  var filteredRecords = [VocRecord]()
  var records = [VocRecord]()
  var synthesizer = AVSpeechSynthesizer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = UIColor.vocBackground
    // Setup the Search Controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search"
    if #available(iOS 11.0, *) {
      navigationItem.searchController = searchController
    } else {
      tableView.tableHeaderView = searchController.searchBar
      // Fallback on earlier versions
    }
    definesPresentationContext = true
    
    self.navigationItem.title = "My words"
    let btnSearch = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(showSearchBar))
    self.navigationItem.setRightBarButton(btnSearch, animated: false)
    
    let nib = UINib(nibName: "VocRecordTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "VocRecordTableViewCell")
      // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    records = DAO.shared.recordsSortedByCreationDate()
    tableView.reloadData()
    
    self.navigationItem.title = "My words (\(records.count))"
  }
  
  @objc private func showSearchBar() {
    searchController.isActive = true
    searchController.searchBar.becomeFirstResponder()
  }
  private func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredRecords = records.filter({( record : VocRecord) -> Bool in
      return record.word.spelling.lowercased().contains(searchText.lowercased()) ||
             record.trans.spelling.lowercased().contains(searchText.lowercased())
    })
    
    tableView.reloadData()
  }
  
  private func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
}

extension RecordsViewController: VocRecordTableViewCellDelegate {
  func pronounce(text: String?) {
    if let r = text {
      let match = records.filter { $0.word.spelling == text }
      if let w = match[safe: 0] {
        let code = w.vocabulary.sourceLang.code.rawValue
        let utterance = AVSpeechUtterance(string: r)
        utterance.voice = AVSpeechSynthesisVoice(language: code)
        utterance.rate = 0.4
        synthesizer.speak(utterance)
      }
    }
  }
}

extension RecordsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredRecords.count
    }
    return records.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //wordPairCellId
    let cell = tableView.dequeueReusableCell(withIdentifier: "VocRecordTableViewCell", for: indexPath) as! VocRecordTableViewCell
    let r: VocRecord
    if isFiltering() {
      r = filteredRecords[indexPath.row]
    } else {
      r = records[indexPath.row]
    }
    cell.lblWord.text = r.word.spelling
    cell.lblTranslation.text = r.trans.spelling
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MMM-YYYY HH:mm"
    
    cell.lblNextDisplay.text = dateFormatter.string(from: r.nextDisplayDate)
    if r.word.partOfSpeech.count > 0 {
      cell.lblPartOfSpeech.text = "(" + r.word.partOfSpeech + ")"
    } else {
      cell.lblPartOfSpeech.text = nil
    }
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let alert = UIAlertController(title: "Do you really want to delete record", message: "This action is not revertable", preferredStyle: .alert)
      let confirm = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
        if let r = self?.records[safe: indexPath.row] {
          DAO.shared.deleteRecord(by: r.identifier)
          self?.records.remove(at: indexPath.row)
          self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
      })
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alert.addAction(confirm)
      alert.addAction(cancel)
      present(alert, animated: true, completion: nil)
    }
  }
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return !isFiltering()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering() {

    }
  }
}

extension RecordsViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}

