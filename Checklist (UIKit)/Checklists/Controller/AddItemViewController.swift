//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Борис on 17.01.2021.
//

import UIKit

class AddItemViewController: UITableViewController {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    textField.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  // MARK: - Actions
  @IBAction func save() {
    print("Contents of the text field: \(textField.text!)")
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }
}

extension AddItemViewController: UITextFieldDelegate {

  // MARK: - Text Field Delegates
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let oldText = textField.text!
    let stringRange = Range(range, in: oldText)!
    let newText = oldText.replacingCharacters(in: stringRange, with: string)
    textField.text = newText

    saveBarButton.isEnabled = !newText.isEmpty

    return true
  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    saveBarButton.isEnabled = false

    return true
  }
}
