//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Борис on 17.01.2021.
//

import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!
  @IBOutlet weak var shouldRemidSwitch: UISwitch!
  @IBOutlet weak var datePicker: UIDatePicker!

  weak var delegate: ItemDetailViewControllerDelegate?
  var itemToEdit: ChecklistItem?

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    textField.delegate = self

    // Configure for edit mode
    if let item = itemToEdit {
      textField.text = item.name
      title = "Edit item"
      shouldRemidSwitch.isOn = item.shouldRemind
      datePicker.date = item.dueDate
      saveBarButton.isEnabled = true
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  // MARK: - Actions
  @IBAction func save() {
    if let item = itemToEdit {
      item.name = textField.text!
      item.shouldRemind = shouldRemidSwitch.isOn
      item.dueDate = datePicker.date
      item.scheduleNotification()
      delegate?.itemDetailViewController(self, didFinishEditing: item)
    } else {
      let item = ChecklistItem(name: textField.text!, shouldRemind: shouldRemidSwitch.isOn, dueDate: datePicker.date)
      item.scheduleNotification()
      delegate?.itemDetailViewController(self, didFinishAdding: item)
    }
  }

  @IBAction func shouldRemidToggled(_ sender: UISwitch) {
    textField.resignFirstResponder()

    if sender.isOn {
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound]) { _,_  in }
    }
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    delegate?.itemDetailViewControllerDidCancel(self)
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }
}

extension ItemDetailViewController: UITextFieldDelegate {

  // MARK: - Text Field Delegates
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let oldText = textField.text!
    let stringRange = Range(range, in: oldText)!
    let newText = oldText.replacingCharacters(in: stringRange, with: string)
    saveBarButton.isEnabled = !newText.isEmpty

    return true
  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    saveBarButton.isEnabled = false

    return true
  }
}
