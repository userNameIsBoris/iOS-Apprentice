//
//  HIghScoreItem.swift
//  Bullseye
//
//  Created by Boris Ezhov on 22.12.2020.
//

import Foundation

class HighScoreItem: NSObject, Codable {
  var name: String
  var score: Int

  init(name: String = "", score: Int = 0) {
    self.name = name
    self.score = score
  }
}
