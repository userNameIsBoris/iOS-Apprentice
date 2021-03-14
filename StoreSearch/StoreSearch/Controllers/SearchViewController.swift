//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Борис on 01.03.2021.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!

  var searchResults: [SearchResult] = []
  var dataTask: URLSessionDataTask?
  private var hasSearched = false
  private var isLoading = false

  var landscapeVC: LandscapeViewController?

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
    tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    tableView.tableFooterView = UIView()
  }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)

    switch newCollection.verticalSizeClass {
    case .compact:
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    @unknown default:
      break
    }
  }

  // MARK: - Actions
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      let indexPath = sender as! IndexPath
      let controller = segue.destination as! DetailViewController

      controller.searchResult = searchResults[indexPath.row]
    }
  }

  // MARK: - Helper Methods
  func iTunesURL(searchText: String, category: Int) -> URL {
    let kind: String
    switch category {
      case 1:
        kind = "musicTrack"
      case 2:
        kind = "software"
      case 3:
        kind = "ebook"
      default:
        kind = ""
    }

    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let stringUrl = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)"
    let url = URL(string: stringUrl)
    return url!
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

  // MARK: Landscape Helpers
  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    guard landscapeVC == nil else { return }

    landscapeVC = storyboard!.instantiateViewController(identifier: "LandscapeViewController") as? LandscapeViewController

    if let controller = landscapeVC {
      controller.searchResults = searchResults
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      searchBar.resignFirstResponder()

      view.addSubview(controller.view)
      addChild(controller)

      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 1
        self.presentedViewController?.view.alpha = 0
      }) { _ in
        controller.didMove(toParent: self)
        if self.presentedViewController != nil {
          self.dismiss(animated: false)
        }
      }
    }
  }

  func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    if let controller = landscapeVC {
      controller.willMove(toParent: nil)

      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 0
        self.presentedViewController?.view.alpha = 0
      }) { _ in
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        self.landscapeVC = nil
      }
    }
  }
}

// MARK: - Search Bar Delegate Extension
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }

  func performSearch() {
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()

      dataTask?.cancel()
      isLoading = true
      tableView.reloadData()

      hasSearched = true
      searchResults = []

      let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
      let session = URLSession.shared
      dataTask = session.dataTask(with: url) { data, response, error in
        if let error = error as NSError?, error.code == -999 {
          return
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          if let data = data {
            self.searchResults = self.parse(data: data)
            self.searchResults.sort { $0 < $1 }
            DispatchQueue.main.async {
              self.isLoading = false
              self.tableView.reloadData()
            }
            return
          }
        } else {
          print("Failure! \(response!)")
        }
        DispatchQueue.main.async {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      }
      dataTask?.resume()
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
      cell.configure(for: searchResult)
      return cell
    }
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return searchResults.isEmpty || isLoading ? nil : indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    performSegue(withIdentifier: "ShowDetail", sender: indexPath)
  }
}
