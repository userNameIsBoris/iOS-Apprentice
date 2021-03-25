//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Boris Ezhov on 24.01.2021.
//

import UIKit

class AllListsViewController: UITableViewController {
  private let cellIdentifier = "ChecklistCell"
  var dataModel: DataModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    // View setup
    navigationController?.navigationBar.prefersLargeTitles = true
    tableView.tableFooterView = UIView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    navigationController?.delegate = self

    // Show screen that the user was previously viewing
    let index = dataModel.indexOfSelectedChecklist
    if index >= 0 && index < dataModel.lists.count { // If the user was on the main screen, the value is -1
      let checklist = dataModel.lists[index]
      performSegue(withIdentifier: "showChecklist", sender: checklist)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  // MARK: - Helper Methods
  private func configureDetailTextInCell(_ cell: UITableViewCell, withChecklist checklist: Checklist) {
    let uncheckedItemsCount = checklist.countUncheckedItems()
    switch uncheckedItemsCount {
    case 0 where checklist.items.count == 0:
      cell.detailTextLabel!.text = "No items"
    case 0 where checklist.items.count != 0:
      cell.detailTextLabel!.text = "All done!"
    default:
      cell.detailTextLabel!.text = "\(uncheckedItemsCount) remaining"
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
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.lists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let checklist = dataModel.lists[indexPath.row]
    let cell: UITableViewCell!
    if let tempCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
      cell = tempCell
    } else {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
    }

    // Configure cell
    cell.imageView!.image = UIImage(named: checklist.iconName)
    cell.textLabel!.text = checklist.name
    configureDetailTextInCell(cell, withChecklist: checklist)
    cell.detailTextLabel!.textColor = UIColor.lightGray
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

// MARK: - List Detail View Controller Delegate Extension
extension AllListsViewController: ListDetailViewControllerDelegate {
  func ListDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
    navigationController?.popViewController(animated: true)
  }

  func ListDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
    dataModel.lists.append(checklist)
    dataModel.sortChecklists()
    tableView.reloadData()

    navigationController?.popViewController(animated: true)
  }

  func ListDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
    dataModel.sortChecklists()
    tableView.reloadData()

    navigationController?.popViewController(animated: true)
  }
}

// MARK: - Navigation Controller Delegate Extension
extension AllListsViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if viewController === self {
      dataModel.indexOfSelectedChecklist = -1
    }
  }
}
