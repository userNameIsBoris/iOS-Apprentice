//
//  ChecklisItem.swift
//  Checklist
//
//  Created by Boris Ezhov on 08.12.2020.
//

import Foundation

struct ChecklistItem: Identifiable, Codable {
  let id: UUID
  var name: String
  var isChecked: Bool

  init(name: String = "", isChecked: Bool = false) {
    self.id = UUID()
    self.name = name
    self.isChecked = isChecked
  }
}
