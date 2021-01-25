//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Борис on 17.01.2021.
//

import Foundation

class ChecklistItem: Equatable, Codable {
  var id: UUID
  var name: String
  var isChecked = false

  init(name: String) {
    self.id = UUID()
    self.name = name
  }

  // Equatable 
  static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.id == rhs.id
  }
}
