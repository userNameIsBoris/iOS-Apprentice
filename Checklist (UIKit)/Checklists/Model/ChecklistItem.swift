//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Борис on 17.01.2021.
//

import Foundation

class ChecklistItem {
  var name: String
  var isChecked = false

  init(name: String) {
    self.name = name
  }
}
