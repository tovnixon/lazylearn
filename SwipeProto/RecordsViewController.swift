//
//  RecordsViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/26/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "My words"
    let nib = UINib(nibName: "RecordTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "RecordTableViewCellId")
      // Do any additional setup after loading the view.
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
    let count = DAO.shared.fetchAllWords().count
    self.navigationItem.title = "My words (\(count))"
  }
}

extension RecordsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DAO.shared.fetchAllWords().count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCellId", for: indexPath) as! RecordTableViewCell
    if let r = DAO.shared.fetchAllWords()[safe: indexPath.row] {
      cell.lblWord.text = r.word
      cell.lblTranslation.text = r.trans
    }
    return cell
  }
}

