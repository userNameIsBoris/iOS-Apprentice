//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Boris Ezhov on 01.03.2021.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!

  private var search = Search()

  weak var splitViewDetail: DetailViewController?
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

    if UIDevice.current.userInterfaceIdiom == .phone {
      searchBar.becomeFirstResponder()
    }
    title = NSLocalizedString("Search", comment: "Split view primary button")
    tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    tableView.tableFooterView = UIView()
  }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)

    switch newCollection.verticalSizeClass {
    case .compact where newCollection.horizontalSizeClass == .compact:
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    default:
      break
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard UIDevice.current.userInterfaceIdiom == .phone else { return }
    navigationController?.navigationBar.isHidden = true
  }

  // MARK: - Actions
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let array) = search.state {
        let controller = segue.destination as! DetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = array[indexPath.row]
        controller.isPopUp = true
        controller.searchResult = searchResult
      }
    }
  }

  // MARK: - Private Methods
  private func hidePrimaryPane() {
    UIView.animate(
      withDuration: 0.25,
      animations: {
        self.splitViewController?.preferredDisplayMode = .secondaryOnly
      }) { _ in
      self.splitViewController?.preferredDisplayMode = .automatic
    }
  }

  // MARK: - Helper Methods
  func showNetworkError() {
    let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error alert: title"), message: NSLocalizedString("There was an error accessing to iTunes Store.\nPlease try again.", comment: "Error alert: message"), preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    present(alert, animated: true)
  }

  // MARK: Landscape Helpers
  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    guard landscapeVC == nil else { return }

    landscapeVC = storyboard!.instantiateViewController(identifier: "LandscapeViewController") as? LandscapeViewController

    if let controller = landscapeVC {
      controller.search = search
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
      }, completion: { _ in
        if self.presentedViewController != nil {
          self.dismiss(animated: true)
        }
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        self.landscapeVC = nil
      })
    }
  }
}

// MARK: - Search Bar Delegate Extension
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }

  func performSearch() {
    search.performSearch(for: searchBar.text!, category: Search.Category(rawValue: segmentedControl.selectedSegmentIndex)!) { success in
      if !success {
        self.showNetworkError()
      }
      self.tableView.reloadData()
      self.landscapeVC?.searchResultsReceived()
    }

    tableView.reloadData()
    searchBar.resignFirstResponder()
  }

  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: - Table View Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .notSearchedYet:
      return 0
    case .loading:
      return 1
    case .noResults:
      return 1
    case .results(let array):
      return array.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch search.state {
    case .notSearchedYet:
      fatalError("Should never get there")
    case .loading:
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .noResults:
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
      return cell
    case .results(let array):
      let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = array[indexPath.row]
      cell.configure(for: searchResult)
      return cell
    }
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      return nil
    case .results:
      return indexPath
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchBar.resignFirstResponder()
    if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    } else if case .results(let array) = search.state {
      if splitViewController!.displayMode != .oneBesideSecondary {
        hidePrimaryPane()
      }
      splitViewDetail?.searchResult = array[indexPath.row]
    }
  }
}
