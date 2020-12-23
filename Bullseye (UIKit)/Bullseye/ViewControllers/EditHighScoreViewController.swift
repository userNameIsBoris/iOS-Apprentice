//
//  EditHighScoreViewController.swift
//  Bullseye
//
//  Created by Борис on 22.12.2020.
//

import UIKit

protocol EditHighScoreViewControllerDelegate: class {
    func editHighScoreViewControllerDidCancel(_ controller: EditHighScoreViewController)
    func editHighScoreViewController(_ controller: EditHighScoreViewController, didFinishEditing item: HighScoreItem)
}

class EditHighScoreViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!

    weak var delegate: EditHighScoreViewControllerDelegate?
    var highScoreItem: HighScoreItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = highScoreItem.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - Actions
    @IBAction func done() {
        highScoreItem.name = textField.text!

        delegate?.editHighScoreViewController(self, didFinishEditing: highScoreItem)
    }

    @IBAction func cancel() {
        delegate?.editHighScoreViewControllerDidCancel(self)
    }

    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    // MARK: - Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)

        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
}
