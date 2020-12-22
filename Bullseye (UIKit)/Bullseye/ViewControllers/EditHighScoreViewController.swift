//
//  EditHighScoreViewController.swift
//  Bullseye
//
//  Created by Борис on 22.12.2020.
//

import UIKit

class EditHighScoreViewController: UITableViewController {

    // MARK: - Actions

    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
