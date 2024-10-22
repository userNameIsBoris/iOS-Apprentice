//
//  Checklist.swift
//  Checklists
//
//  Created by Boris Ezhov on 24.01.2021.
//

import Foundation

class Checklist: Equatable, Codable {
  var id: UUID
  var name: String
  var items: [ChecklistItem] = []
  var iconName: String

  init(name: String, iconName: String = "No Icon") {
    self.id = UUID()
    self.name = name
    self.iconName = iconName
  }

  // MARK: - Methods
  func countUncheckedItems() -> Int {
    var count = 0
    for item in items where !item.isChecked {
      count += 1
    }
    return count
  }

  // Sort
  func sortChecklistItems() {
    items.sort { item1, item2 in
      return item1.dueDate.compare(item2.dueDate) == .orderedAscending
    }
  }

  // Equatable
  static func == (lhs: Checklist, rhs: Checklist) -> Bool {
    return lhs.id == rhs.id
  }
}
