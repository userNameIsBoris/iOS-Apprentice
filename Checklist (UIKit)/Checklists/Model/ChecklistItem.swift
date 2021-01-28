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
  var isChecked: Bool

  init(name: String, isChecked: Bool = false) {
    self.id = UUID()
    self.name = name
    self.isChecked = isChecked
  }

  // Equatable 
  static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.id == rhs.id
  }
}
