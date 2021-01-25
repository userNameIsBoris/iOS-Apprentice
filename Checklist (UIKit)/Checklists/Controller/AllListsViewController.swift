//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Борис on 24.01.2021.
//

import UIKit

class AllListsViewController: UITableViewController {

  let cellIdentifier = "ChecklistCell"
  var checklists: [Checklist] = [
    Checklist(name: "Birthdays"),
    Checklist(name: "Groceries"),
    Checklist(name: "Cool Apps"),
    Checklist(name: "To Do"),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

    // View setup
    navigationController?.navigationBar.prefersLargeTitles = true
    tableView.tableFooterView = UIView()
  }

  // MARK: - Helper Methods

  // MARK: Data Persistence
  // Space for chapter 17

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    // Show checklist
    if segue.identifier == "showChecklist" {
      let controller = segue.destination as! ChecklistViewController
      let checklist = sender as! Checklist

      controller.checklist = checklist
    }

    // Add checklist
    if segue.identifier == "AddChecklist" {
      let controller = segue.destination as! ListDetailViewController
      controller.delegate = self
    }

    // Edit checklist
    if segue.identifier == "" {
      
    }
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return checklists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let checklist = checklists[indexPath.row]

    // Configure cell
    cell.textLabel!.text = checklist.name
    cell.accessoryType = .detailDisclosureButton

    return cell
  }

  // MARK: Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let checklist = checklists[indexPath.row]
    performSegue(withIdentifier: "showChecklist", sender: checklist)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    checklists.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }

  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let controller = storyboard?.instantiateViewController(identifier: "ListDetailViewController") as! ListDetailViewController
    controller.delegate = self
    let checklist = checklists[indexPath.row]
    controller.checklistToEdit = checklist

    navigationController?.pushViewController(controller, animated: true)
  }
}

extension AllListsViewController: ListDetailViewControllerDelegate {

  // MARK: - List Detail ViewController Delegates
  func ListDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
    navigationController?.popViewController(animated: true)
  }

  func ListDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
    let newIndex = checklists.count
    checklists.append(checklist)
    let indexPath = IndexPath(row: newIndex, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)

    navigationController?.popViewController(animated: true)
  }

  func ListDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
    if let index = checklists.firstIndex(of: checklist) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        cell.textLabel!.text = checklist.name
      }
    }
    navigationController?.popViewController(animated: true)
  }
}

