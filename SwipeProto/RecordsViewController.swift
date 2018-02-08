//
//  RecordsViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit
import AVFoundation

class RecordsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  let searchController = UISearchController(searchResultsController: nil)
  var filteredRecords = [VocRecord]()
  var records = DAO.shared.fetchAllWords()
  var synthesizer = AVSpeechSynthesizer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    let nib = UINib(nibName: "VocRecordTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "VocRecordTableViewCell")
      // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    records = DAO.shared.fetchAllWords()
    tableView.reloadData()
    
    self.navigationItem.title = "My words (\(records.count))"
  }
  
  private func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredRecords = records.filter({( record : VocRecord) -> Bool in
      return record.word.lowercased().contains(searchText.lowercased()) ||
             record.trans.lowercased().contains(searchText.lowercased())
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
      let utterance = AVSpeechUtterance(string: r)
      utterance.voice = AVSpeechSynthesisVoice(language: "en")
      utterance.rate = 0.4
      synthesizer.speak(utterance)
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
    cell.lblWord.text = r.word
    cell.lblTranslation.text = r.trans
    if let partOfSppech = r.partOfSpeech {
      cell.lblPartOfSpeech.text = "(" + partOfSppech + ")"
    } else {
      cell.lblPartOfSpeech.text = nil
    }
    cell.delegate = self
    return cell
  }
}

extension RecordsViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}

