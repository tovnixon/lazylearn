//
//  StepRepetition.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 1/23/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation

enum RecallGrade: Int {
  case easy = 3
  case normal = 2
  case hard = 1
  case fail = 0
  
}

struct StepRepetitionRecord: Codable {
  var eFactor: Double = 2.5 // Easiness factor
  var interval: Int32 = 0   // in days. In how many days record should be showed next time
  var repetition: Int32 = 0 // number of repetitions

  // Calculate when data should be proposed to recall next time
  // Call immediately after current displaying and evaluating recall difficulty
  // @param grade recall difficulty
  // @return interval to next proposal in days
  
  mutating func doRepetition(with grade: RecallGrade) -> Int32 {
    if grade.rawValue >= 2 {
      if repetition == 0 {
        repetition = 1
        interval = 1
      } else if repetition == 1 {
        repetition = 2
        interval = 6
      } else {
        interval = Int32((Double(interval) * eFactor).rounded())
        repetition += 1
      }
    } else {
      repetition = 0
      interval = 0
    }
    let dGrade = Double(3 - grade.rawValue)
    eFactor = eFactor + (0.1 - dGrade * (0.08 + dGrade * 0.02))

    if eFactor < 1.3 {
      eFactor = 1.3
    }
    return interval
  }
}
