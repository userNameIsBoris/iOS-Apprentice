//
//  HighScoresViewController.swift
//  Bullseye
//
//  Created by Boris Ezhov on 20.12.2020.
//

import UIKit

class HighScoresViewController: UITableViewController {
  private var items: [HighScoreItem] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView()
    items = PersistencyHelper.loadHighScores()
    guard items.count == 0 else { return }
    resetHighScores()
  }

  // MARK: - Actions
  @IBAction func resetHighScores() {
    items = [
      HighScoreItem(name: "The reader of this book", score: 50000),
      HighScoreItem(name: "Manda", score: 10000),
      HighScoreItem(name: "Joey", score: 5000),
      HighScoreItem(name: "Adam", score: 1000),
      HighScoreItem(name: "Eli", score: 500),
      HighScoreItem(name: "Noob", score: 0),
    ]

    tableView.reloadData()
    PersistencyHelper.saveHighScores(items)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let controller = segue.destination as! EditHighScoreViewController
    controller.delegate = self
    guard let indexPath = tableView.indexPath(for: sender as! UITableViewCell) else { return }
    controller.highScoreItem = items[indexPath.row]
  }

  // MARK: - Private Methods
  private func configureCell(_ cell: UITableViewCell, forItem item: HighScoreItem) {
    let nameLabel = cell.viewWithTag(1000) as! UILabel
    let scoreLabel = cell.viewWithTag(2000) as! UILabel
    nameLabel.text = item.name
    scoreLabel.text = String(item.score)
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreItem", for: indexPath)
    let item = items[indexPath.row]
    configureCell(cell, forItem: item)
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
}

// MARK: - Edit High Score View Controller Delegate Extension
extension HighScoresViewController: EditHighScoreViewControllerDelegate {
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
}
