//
//  DataModel.swift
//  Checklists
//
//  Created by Boris Ezhov on 26.01.2021.
//

import Foundation

class DataModel {
  var lists: [Checklist] = []
  var indexOfSelectedChecklist: Int {
    get {
      return UserDefaults.standard.integer(forKey: "ChecklistIndex")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
    }
  }

  init() {
    loadChecklists()
    registerDefaults()
    handleFirstTime()
  }

  // MARK: - Methods

  // MARK: Data Persistence
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
      sortChecklists()
      for list in lists {
        list.sortChecklistItems()
      }
    } catch {
      print("Error decoding item array: \(error)")
    }
  }

  // MARK: User Defaults
  func registerDefaults() {
    let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true]
    UserDefaults.standard.register(defaults: dictionary)
  }

  func handleFirstTime() {
    let userDefaults = UserDefaults.standard
    let firstTime = userDefaults.bool(forKey: "FirstTime")

    guard firstTime else { return }
    let checklist = Checklist(name: "List")
    lists.append(checklist)
    indexOfSelectedChecklist = 0
    userDefaults.set(false, forKey: "FirstTime")
  }

  // MARK: Sort
  func sortChecklists() {
    lists.sort { list1, list2 in
      return list1.name.localizedCompare(list2.name) == .orderedAscending
    }
  }
}
