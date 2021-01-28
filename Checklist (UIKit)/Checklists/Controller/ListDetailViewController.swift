//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Борис on 25.01.2021.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
  func ListDetailViewControllerDidCancel(_ controller: ListDetailViewController)
  func ListDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
  func ListDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!
  @IBOutlet weak var iconImage: UIImageView!

  weak var delegate: ListDetailViewControllerDelegate?
  var checklistToEdit: Checklist?
  var iconName = "Folder"

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    textField.delegate = self

    // Configure for edit mode
    if let checklist = checklistToEdit {
      title = "Edit Checklist"
      textField.text = checklist.name
      saveBarButton.isEnabled = true
      iconName = checklist.iconName
    }
    iconImage.image = UIImage(named: iconName)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  // MARK: - Actions
  @IBAction func save() {
    if let checklist = checklistToEdit {
      checklist.name = textField.text!
      checklist.iconName = iconName
      delegate?.ListDetailViewController(self, didFinishEditing: checklist)
    } else {
      let checklist = Checklist(name: textField.text!, iconName: iconName)
      delegate?.ListDetailViewController(self, didFinishAdding: checklist)
    }
  }

  @IBAction func cancel(_ sender: UIBarButtonItem) {
    delegate?.ListDetailViewControllerDidCancel(self)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pickIcon" {
      let controller = segue.destination as! IconPickerViewController
      controller.delegate = self
    }
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 1 ? indexPath : nil
  }
}

extension ListDetailViewController: UITextFieldDelegate {

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

extension ListDetailViewController: IconPickerViewControllerDelegate {

  // MARK: - Icon Picker ViewController Delegates
  func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
    self.iconName = iconName
    iconImage.image = UIImage(named: iconName)
    navigationController?.popViewController(animated: true)
  }
}
