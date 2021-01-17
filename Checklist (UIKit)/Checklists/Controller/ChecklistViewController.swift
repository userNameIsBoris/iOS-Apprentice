//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Борис on 16.01.2021.
//

import UIKit

class ChecklistViewController: UITableViewController {

  var items: [ChecklistItem] = [
    ChecklistItem(name: "Walk the dog"),
    ChecklistItem(name: "Brush my teeth"),
    ChecklistItem(name: "Learn iOS development"),
    ChecklistItem(name: "Eat ice cream"),
    ChecklistItem(name: "Soccer practice"),
    ChecklistItem(name: "Another one"),
    ChecklistItem(name: "Another two :D"),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.barTintColor = .white
    items[1].isChecked = true
    items[4].isChecked = true
  }

  // MARK: Actions
//  @IBAction func addItem() {
//    let newRowIndex = items.count
//
//    let newItem = ChecklistItem(name: "New row!")
//    newItem.isChecked = true
//    items.append(newItem)
//    items.append(newItem)
//
//    let indexPath = IndexPath(row: newRowIndex, section: 0)
//    let indexPath1 = IndexPath(row: newRowIndex + 1, section: 0)
//    
//    let indexPaths = [indexPath, indexPath1]
//    print(indexPaths)
//    tableView.insertRows(at: indexPaths, with: .automatic)
//  }

  // MARK: - Helper Methods

  // MARK: Cell Configure Methods
  func configureText(cell: UITableViewCell, withItem item: ChecklistItem) {
    guard let textLabel = cell.viewWithTag(1000) as? UILabel else { return }
    textLabel.text = item.name
  }

  func configureCheckmark(cell: UITableViewCell, withItem item: ChecklistItem) {
    cell.accessoryType = item.isChecked ? .checkmark : .none
  }

  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
    let item = items[indexPath.row]

    // Configure cell
    configureText(cell: cell, withItem: item)
    configureCheckmark(cell: cell, withItem: item)

    return cell
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let item = items[indexPath.row]

    item.isChecked.toggle()
    configureCheckmark(cell: cell, withItem: item)

    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    items.remove(at: indexPath.row)

    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
}
