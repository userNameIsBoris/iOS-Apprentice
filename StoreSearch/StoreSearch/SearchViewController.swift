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
  var isLoading = false

  struct TableView {
    struct CellIdentifiers {
      static let searchResultCell = "SearchResultCell"
      static let nothingFoundCell = "NothingFoundCell"
      static let loadingCell = "LoadingCell"
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
    cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)

    searchBar.becomeFirstResponder()
    tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    tableView.tableFooterView = UIView()
  }

  // MARK: - Helper Methods
  func iTunesURL(searchText: String) -> URL {
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let stringUrl = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
    let url = URL(string: stringUrl)
    return url!
  }

  func performStoreRequest(with url: URL) -> Data? {
    do {
      return try Data(contentsOf: url)
    } catch {
      print("Downloading error: \(error.localizedDescription)")
      showNetworkError()
      return nil
    }
  }

  func parse(data: Data) -> [SearchResult] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(ResultArray.self, from: data)
      return result.results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }

  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing to iTunes Store.\nPlease try again.", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    present(alert, animated: true)
  }
}

// MARK: - Search Bar Delegate Extension
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      isLoading = true
      tableView.reloadData()
      hasSearched = true

      searchResults = []

      let queue = DispatchQueue.global()
      let url = iTunesURL(searchText: searchBar.text!)
      queue.async {
        if let data = self.performStoreRequest(with: url) {
          self.searchResults = self.parse(data: data)
          self.searchResults.sort { $0 < $1 }
          DispatchQueue.main.async {
            self.isLoading = false
            self.tableView.reloadData()
          }
          return
        }
      }
    }
  }

  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: - Table View Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.isEmpty {
      return 1
    } else {
      return searchResults.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if searchResults.isEmpty {
      return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.nameLabel.text = searchResult.name
      cell.artistNameLabel.text = searchResult.artist.isEmpty ? "Unknown" : String(format: "%@ (%@)", searchResult.artist, searchResult.type)
      return cell
    }
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return searchResults.isEmpty || isLoading ? nil : indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
