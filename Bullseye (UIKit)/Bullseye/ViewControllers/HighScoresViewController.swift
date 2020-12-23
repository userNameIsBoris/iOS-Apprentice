//
//  HighScoresViewController.swift
//  Bullseye
//
//  Created by Борис on 20.12.2020.
//

import UIKit

class HighScoresViewController: UITableViewController, EditHighScoreViewControllerDelegate {
    var items: [HighScoreItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        items = PersistencyHelper.loadHighScores()
        if items.count == 0 {
            resetHighScores()
        }
    }

    // MARK: - Table view data sourcex
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreItem", for: indexPath)

        let item = items[indexPath.row]

        let nameLabel = cell.viewWithTag(1000) as! UILabel
        let scoreLabel = cell.viewWithTag(2000) as! UILabel

        nameLabel.text = item.name
        scoreLabel.text = String(item.score)

        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)

        let indexPaths = [indexPath]

        tableView.deleteRows(at: indexPaths, with: .automatic)

        PersistencyHelper.saveHighScores(items)
    }

    // MARK: - Actions
    @IBAction func resetHighScores() {
        items = [HighScoreItem]()
        let item0 = HighScoreItem()
        let item1 = HighScoreItem()
        let item2 = HighScoreItem()
        let item3 = HighScoreItem()
        let item4 = HighScoreItem()
        let item5 = HighScoreItem()

        item0.name = "The reader of this book"
        item0.score = 50000
        item1.name = "Manda"
        item1.score = 10000
        item2.name = "Joey"
        item2.score = 5000
        item3.name = "Adam"
        item3.score = 1000
        item4.name = "Eli"
        item4.score = 500
        item5.name = "Noob"
        item5.score = 0

        items.append(item0)
        items.append(item1)
        items.append(item2)
        items.append(item3)
        items.append(item4)
        items.append(item5)

        tableView.reloadData()
        PersistencyHelper.saveHighScores(items)
    }

    // MARK: - Edit High Score ViewController Delegates
    func editHighScoreViewController(_ controller: EditHighScoreViewController, didFinishEditing item: HighScoreItem) {
        if let index = items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            let indexPaths = [indexPath]
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }

        PersistencyHelper.saveHighScores(items)
        navigationController?.popViewController(animated: true)
    }

    func editHighScoreViewControllerDidCancel(_ controller: EditHighScoreViewController) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! EditHighScoreViewController
        controller.delegate = self
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            controller.highScoreItem = items[indexPath.row]
        }
    }
}
