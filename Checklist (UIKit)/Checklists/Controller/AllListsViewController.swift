//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Борис on 24.01.2021.
//

import UIKit

class AllListsViewController: UITableViewController {

  let cellIdentifier = "ChecklistCell"
  var dataModel: DataModel!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

    // View setup
    navigationController?.navigationBar.prefersLargeTitles = true
    tableView.tableFooterView = UIView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    navigationController?.delegate = self

    // Show screen that the user was previously viewing
    let index = dataModel.indexOfSelectedChecklist
    if index >= 0 && index < dataModel.lists.count  { // If the user was on the main screen, the value is -1
      let checklist = dataModel.lists[index]
      performSegue(withIdentifier: "showChecklist", sender: checklist)
    }
  }

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
    return dataModel.lists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let checklist = dataModel.lists[indexPath.row]

    // Configure cell
    cell.textLabel!.text = checklist.name
    cell.accessoryType = .detailDisclosureButton

    return cell
  }

  // MARK: Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataModel.indexOfSelectedChecklist = indexPath.row
    let checklist = dataModel.lists[indexPath.row]
    performSegue(withIdentifier: "showChecklist", sender: checklist)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    dataModel.lists.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }

  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let controller = storyboard?.instantiateViewController(identifier: "ListDetailViewController") as! ListDetailViewController
    controller.delegate = self
    let checklist = dataModel.lists[indexPath.row]
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
    let newIndex = dataModel.lists.count
    dataModel.lists.append(checklist)
    let indexPath = IndexPath(row: newIndex, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)

    navigationController?.popViewController(animated: true)
  }

  func ListDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
    if let index = dataModel.lists.firstIndex(of: checklist) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        cell.textLabel!.text = checklist.name
      }
    }
    navigationController?.popViewController(animated: true)
  }
}

extension AllListsViewController: UINavigationControllerDelegate {

  // MARK: - Navigation Controller Delegates
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if viewController === self {
      dataModel.indexOfSelectedChecklist = -1
    }
  }
}
