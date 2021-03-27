//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Boris Ezhov on 21.03.2021.
//

import UIKit

protocol MenuViewControllerDelegate: class {
  func menuViewControllerSendEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {
  weak var delegate: MenuViewControllerDelegate?

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row == 0 {
      delegate?.menuViewControllerSendEmail(self)
    }
  }
}
