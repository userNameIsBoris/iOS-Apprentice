//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Boris Ezhov on 16.01.2021.
//

import UIKit

class ChecklistViewController: UITableViewController {
  var checklist: Checklist!

  override func viewDidLoad() {
    super.viewDidLoad()

    // View setup
    tableView.tableFooterView = UIView()
    navigationItem.largeTitleDisplayMode = .never
    title = checklist.name
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Add item
    if segue.identifier == "AddItem" {
      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self
    }

    // Edit item
    if segue.identifier == "EditItem" {
      guard let indexPath = tableView.indexPath(for: sender as! UITableViewCell) else { return }
      let controller = segue.destination as! ItemDetailViewController
      controller.delegate = self
      controller.itemToEdit = checklist.items[indexPath.row]
    }
  }

  // MARK: - Helper Methods
  private func configureTextAndDate(for cell: UITableViewCell, with item: ChecklistItem) {
    guard let textLabel = cell.viewWithTag(1000) as? UILabel, let dueDateLabel = cell.viewWithTag(1002) as? UILabel else { return }
    textLabel.text = item.name
    dueDateLabel.text = item.dueDateString
  }

  private func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
    guard let checkmarkLabel = cell.viewWithTag(1001) as? UILabel else { return }
    checkmarkLabel.text = item.isChecked ? "√" : ""
  }

  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return checklist.items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
    let item = checklist.items[indexPath.row]

    // Configure cell
    configureTextAndDate(for: cell, with: item)
    configureCheckmark(for: cell, with: item)

    return cell
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let item = checklist.items[indexPath.row]
    item.isChecked.toggle()
    configureCheckmark(for: cell, with: item)
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    checklist.items.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
}

// MARK: - Item Detail View Controller Delegate Extension
extension ChecklistViewController: ItemDetailViewControllerDelegate {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
    navigationController?.popViewController(animated: true)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
    checklist.items.append(item)
    checklist.sortChecklistItems()
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
    checklist.sortChecklistItems()
    tableView.reloadData()
    navigationController?.popViewController(animated: true)
  }
}
