//
//  DataModel.swift
//  Checklists
//
//  Created by Борис on 26.01.2021.
//

import Foundation

class DataModel {
  var lists: [Checklist] = []

  init() {
    loadChecklists()
  }

  // MARK: - Methods
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("DataModel.plist")
  }

  func saveChecklists() {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(lists)
      try data.write(to: dataFilePath(), options: .atomic)
    } catch {
      print("Error encoding item array: \(error)")
    }
  }

  func loadChecklists() {
    let path = dataFilePath()
    guard let data = try? Data(contentsOf: path) else { return }
    let decoder = PropertyListDecoder()
    do {
      lists = try decoder.decode([Checklist].self, from: data)
    } catch {
      print("Error decoding item array: \(error)")
    }
  }
}
