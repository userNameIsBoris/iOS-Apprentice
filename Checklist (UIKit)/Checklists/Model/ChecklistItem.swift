//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Борис on 17.01.2021.
//

import Foundation

class ChecklistItem: Equatable {
  static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.name == rhs.name && lhs.isChecked == rhs.isChecked
  }

  var name: String
  var isChecked = false

  init(name: String) {
    self.name = name
  }
}
