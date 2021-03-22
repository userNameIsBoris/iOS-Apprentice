//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Борис on 12.03.2021.
//

import UIKit

class LandscapeViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!

  var search: Search!
  
  private var firstTime = true
  private var downloads = [URLSessionDownloadTask]()

  deinit {
    for task in downloads {
      task.cancel()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Remove constraints from main view
    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true

    // Remove constraints from scroll view
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true

    // Remove constraints from page control
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true

    view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    pageControl.numberOfPages = 0
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let safeFrame = view.safeAreaLayoutGuide.layoutFrame
    scrollView.frame = safeFrame
    pageControl.frame = CGRect(
      x: safeFrame.origin.x,
      y: safeFrame.size.height - pageControl.frame.size.height,
      width: safeFrame.size.width,
      height: pageControl.frame.size.height)

    if firstTime {
      firstTime = false
      switch search.state {
      case .notSearchedYet:
        break
      case .noResults:
        showNothingFoundLabel()
      case .loading:
        showSpinner()
      case .results(let array):
        tileButtons(array)
      }
    }
  }

  // MARK: - Actions
  @IBAction func pageChanged(_ sender: UIPageControl) {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
      self.scrollView.contentOffset = CGPoint(
        x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
        y: 0)
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail", case .results(let array) = search.state {
      let controller = segue.destination as! DetailViewController
      let button = sender as! UIButton
      let searchResult = array[button.tag - 2000]
      controller.isPopUp = true
      controller.searchResult = searchResult
    }
  }

  // MARK: - Helper Methods
  func searchResultsReceived() {
    hideSpinner()

    switch search.state {
    case .notSearchedYet, .loading:
      break
    case .noResults:
      showNothingFoundLabel()
    case .results(let array):
      tileButtons(array)
    }
  }

  @objc func buttonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetail", sender: sender)
  }

  // MARK: - Private Methods
  func tileButtons(_ searchResults: [SearchResult]) {
    let itemWidth: CGFloat = 94
    let itemHeight: CGFloat = 88
    var columnsPerPage = 0
    var rowsPerPage = 0
    var marginX: CGFloat = 0
    var marginY: CGFloat = 0
    let viewHeight = UIScreen.main.bounds.size.height
    let viewWidth = UIScreen.main.bounds.size.width

    columnsPerPage = Int(viewWidth / itemWidth)
    rowsPerPage = Int(viewHeight / itemHeight)
    marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
    marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5

    // Button size
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorizontal = (itemWidth - buttonWidth) / 2
    let paddingVertical = (itemHeight - buttonHeight) / 2

    // Add the buttons
    var row = 0
    var column = 0
    var x = marginX
    for (index, result) in searchResults.enumerated() {
      let button = UIButton(type: .custom)
      button.tag = 2000 + index
      button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      downloadImage(for: result, andPlaceOn: button)
      button.frame = CGRect(
        x: x + paddingHorizontal,
        y: marginY + CGFloat(row) * itemHeight + paddingVertical,
        width: buttonWidth,
        height: buttonHeight)

      scrollView.addSubview(button)

      row += 1
      if row == rowsPerPage {
        row = 0
        column += 1
        x += itemWidth
        if column == columnsPerPage {
          column = 0
          x += marginX * 2
        }
      }
    }

    // Set scroll view content size
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
    scrollView.contentSize = CGSize(
      width: CGFloat(numPages) * viewWidth,
      height: scrollView.bounds.size.height)

    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0
    print("Number of pages: \(numPages)")
  }

  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.center = CGPoint(
      x: scrollView.bounds.midX + 0.5,
      y: scrollView.bounds.midY + 0.5)
    spinner.tag = 1000
    scrollView.addSubview(spinner)
    spinner.startAnimating()
  }

  private func hideSpinner() {
    view.viewWithTag(1000)?.removeFromSuperview()
  }

  private func showNothingFoundLabel() {
    let label = UILabel(frame: CGRect.zero)
    label.text = NSLocalizedString("Nothing Found", comment: "Nothing found label: nothing found")
    label.textColor = UIColor(named: "ArtistName")
    label.backgroundColor = UIColor.clear

    label.sizeToFit()

    var rect = label.frame
    rect.size.width = ceil(rect.size.width / 2) * 2
    rect.size.height = ceil(rect.size.height / 2) * 2
    label.frame = rect

    label.center = CGPoint(
      x: scrollView.bounds.midX,
      y: scrollView.bounds.midY)
    view.addSubview(label)
  }

  private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
    if let url = URL(string: searchResult.imageSmall) {
      let task = URLSession.shared.downloadTask(with: url) { [weak button] url, _, error in
        if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
          DispatchQueue.main.async {
            if let button = button {
              button.setImage(image, for: .normal)
            }
          }
        }
      }
      downloads.append(task)
      task.resume()
    }
  }
}

// MARK: Scroll View Delegate Extension
extension LandscapeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    pageControl.currentPage = page
  }
}
