//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Борис on 16.01.2021.
//

import UIKit

class ChecklistViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }


  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)

    // Configure cell
    if let textLabel = cell.viewWithTag(1000) as? UILabel {
      switch indexPath.row {
      case 0:
        textLabel.text = "Walk the dog"
      case 1:
        textLabel.text = "Brush my teeth"
      case 2:
        textLabel.text = "Learn iOS development"
      case 3:
        textLabel.text = "Soccer practice"
      case 4:
        textLabel.text = "Eat ice cream"
      default:
        textLabel.text = "UFO!"
      }
    }

    return cell
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      // Toggle checkmark on tap
      if cell.accessoryType == .none {
        cell.accessoryType = .checkmark
      } else {
        cell.accessoryType = .none
      }
    }

    tableView.deselectRow(at: indexPath, animated: true)
  }
}

