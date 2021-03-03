//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Борис on 01.03.2021.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  var searchResults: [SearchResult] = []
  var hasSearched = false

  struct TableView {
    struct CellIdentifiers {
      static let searchResultCell = "SearchResultCell"
      static let nothingFoundCell = "NothingFoundCell"
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.becomeFirstResponder()
    tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
  }
}

// MARK: - Search Bar Delegate Extension
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchResults = []
    if searchBar.text! != "justin bieber" {
      for i in 0...2 {
        let name = String(format: "Fake result %d for '%@'", i, searchBar.text!)

        let result = SearchResult(name: name, artistName: searchBar.text!)
        searchResults.append(result)
      }
    }
    hasSearched = true
    tableView.reloadData()
  }

  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: - Table View Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.isEmpty {
      return 1
    } else {
      return searchResults.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if searchResults.isEmpty {
      return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      let result = searchResults[indexPath.row]
      cell.nameLabel.text = result.name
      cell.artistNameLabel.text = result.artistName
      return cell
    }
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return searchResults.isEmpty ? nil : indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
