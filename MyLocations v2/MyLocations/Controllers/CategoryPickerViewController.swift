//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Борис on 08.02.2021.
//

import UIKit

class CategoryPickerViewController: UITableViewController {

  // MARK: - Properties
  var selectedCategoryName = ""
  var selectedIndexPath = IndexPath()

  let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"
  ]

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()

    for i in 0..<categories.count {
      if categories[i] == selectedCategoryName {
        selectedIndexPath = IndexPath(row: i, section: 0)
        break
      }
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickedCategory" {
      let cell = sender as! UITableViewCell
      if let indexPath = tableView.indexPath(for: cell) {
        selectedCategoryName = categories[indexPath.row]
      }
    }
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let categoryName = categories[indexPath.row]

    // Configure cell
    cell.textLabel!.text = categoryName
    cell.accessoryType = categoryName == selectedCategoryName ? .checkmark : .none

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row != selectedIndexPath.row {
      if let newCell = tableView.cellForRow(at: indexPath) {
        newCell.accessoryType = .checkmark
      }
      if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
        oldCell.accessoryType = .none
      }
      selectedIndexPath = indexPath
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
