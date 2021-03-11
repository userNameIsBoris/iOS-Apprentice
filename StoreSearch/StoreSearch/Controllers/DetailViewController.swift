//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Борис on 08.03.2021.
//

import UIKit

class DetailViewController: UIViewController {
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!

  var searchResult: SearchResult!
  var downloadTask: URLSessionDownloadTask?

  required init?(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    transitioningDelegate = self
  }

  deinit {
    downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if searchResult != nil {
      updateUI()
    }
    artworkImageView.layer.cornerRadius = 13

    // Configure Gesture Recognizer
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
  }
    
  // MARK: - Actions
  @IBAction func close() {
    dismiss(animated: true)
  }

  @IBAction func openURL() {
    if let url = URL(string: searchResult.storeURL) {
      UIApplication.shared.open(url, options: [:])
    }
  }

  // MARK: - Helper Methods
  func updateUI() {
    nameLabel.text = searchResult.name
    artistNameLabel.text = searchResult.artist.isEmpty ? "Unknown" : searchResult.artist
    kindLabel.text = searchResult.kind
    genreLabel.text = searchResult.genre

    // Show price
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = searchResult.currency

    let priceText: String

    if searchResult.price.isZero {
      priceText = "Free"
    } else if let text = formatter.string(from: searchResult.price as NSNumber) {
      priceText = text
    } else {
      priceText = ""
    }
    priceButton.setTitle(priceText, for: .normal)

    // Get image
    if let largeImageUrl = URL(string: searchResult.imageLarge) {
      downloadTask = artworkImageView.loadImage(url: largeImageUrl)
    }
  }

}

// MARK: - Gesture Recognizer Delegate Extension
extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view === mainView
  }
}

// MARK: - View Controller Transition Delegate Extension
extension DetailViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideOutAnimationController()
  }
}
