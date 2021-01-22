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
    items[1].isChecked = true
    items[4].isChecked = true
  }

  // MARK: Actions

  // MARK: - Helper Methods

  // MARK: Cell Configure Methods
  func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
    guard let textLabel = cell.viewWithTag(1000) as? UILabel else { return }
    textLabel.text = item.name
  }

  func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
    guard let checkmarkLabel = cell.viewWithTag(1001) as? UILabel else { return }
    checkmarkLabel.text = item.isChecked ? "√" : ""
  }

  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    // Add item segue
    if segue.identifier == "AddItem" {
      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self      
    }

    // Edit item segue
    if segue.identifier == "EditItem" {
      guard let indexPath = tableView.indexPath(for: sender as! UITableViewCell) else { return }

      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self
      controller.itemToEdit = items[indexPath.row]
    }
  }

  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
    let item = items[indexPath.row]

    // Configure cell
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)

    return cell
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let item = items[indexPath.row]

    item.isChecked.toggle()
    configureCheckmark(for: cell, with: item)

    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    items.remove(at: indexPath.row)

    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
}

extension ChecklistViewController: ItemDetailViewControllerDelegate {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
    navigationController?.popViewController(animated: true)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
    let newIndex = items.count
    items.append(item)
    let indexPath = IndexPath(row: newIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)

    navigationController?.popViewController(animated: true)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
    if let index = items.firstIndex(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    navigationController?.popViewController(animated: true)
  }
}


