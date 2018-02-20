//
//  SelectTrainingViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 2/16/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class SelectTrainingViewController: BaseViewController {
  let cellId = "TrainingMethodTableViewCell"
  @IBOutlet weak var tableView: UITableView!
  var trainingMethods = [TrainingMethod]()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationItem.title = "Pick training method"
      
      let tm1 = TrainingMethod(name: "Spaced repetition", description: "The SRS (Spaced Repetition System) is a presentation method that gives you the information before you would forget it and makes sure that it stays constantly fresh in your mind.", icon: UIImage(named: "flash_cards_icon")!)
        let tm2 = TrainingMethod(name: "Flash cards", description: "flash cards", icon: UIImage(named: "spaced_repetition_icon")!)
      trainingMethods.append(tm1)
      trainingMethods.append(tm2)
      DAO.shared.deleteRecord(by: 90)
    }
}

extension SelectTrainingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return trainingMethods.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TrainingMethodTableViewCell
    let method = trainingMethods[indexPath.section]
    cell.bind(trainingMethod: method)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let method = trainingMethods[indexPath.section]
    switch method.name {
    case "Spaced repetition":
      self.performSegue(withIdentifier: "SpaceRepetitionSegue", sender: self)
    case "Flash cards":
      self.performSegue(withIdentifier: "FlashCardsSegue", sender: self)
    default:
      break
    }
  }

}
