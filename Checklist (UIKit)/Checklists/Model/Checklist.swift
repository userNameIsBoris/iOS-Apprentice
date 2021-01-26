//
//  Checklist.swift
//  Checklists
//
//  Created by Борис on 24.01.2021.
//

import Foundation

class Checklist: Equatable, Codable {
  var id: UUID
  var name: String
  var items: [ChecklistItem] = []

  init(name: String) {
    self.id = UUID()
    self.name = name
  }

  // Equatable
  static func == (lhs: Checklist, rhs: Checklist) -> Bool {
    return lhs.id == rhs.id
  }
}
