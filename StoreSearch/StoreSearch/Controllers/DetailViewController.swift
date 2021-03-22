//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Борис on 08.03.2021.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var popUpView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!

  var searchResult: SearchResult! {
    didSet {
      guard isViewLoaded else { return }
      updateUI()
    }
  }
  var downloadTask: URLSessionDownloadTask?
  var isPopUp = false

  required init?(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    transitioningDelegate = self
  }

  deinit {
    downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if isPopUp {
      popUpView.layer.cornerRadius = 10
      // Configure Gesture Recognizer
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
      gestureRecognizer.cancelsTouchesInView = false
      gestureRecognizer.delegate = self
      view.addGestureRecognizer(gestureRecognizer)
    } else {
      mainView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      popUpView.isHidden = true
      guard let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String else { return }
      title = displayName
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showPopover(_:)))
    }
    artworkImageView.layer.cornerRadius = 13

    guard searchResult != nil else { return }
    updateUI()
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
    artistNameLabel.text = searchResult.artist.isEmpty ? NSLocalizedString("Unknown", comment: "Artist name label: unknown") : searchResult.artist
    kindLabel.text = searchResult.type
    genreLabel.text = searchResult.genre

    // Show price
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = searchResult.currency

    let priceText: String

    if searchResult.price.isZero {
      priceText = NSLocalizedString("Free", comment: "Search result price: free")
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
    popUpView.isHidden = false
  }

  @objc func showPopover(_ sender: UIBarButtonItem) {
    guard let popover = storyboard?.instantiateViewController(withIdentifier: "PopoverView") as? MenuViewController else { return }
    popover.modalPresentationStyle = .popover
    if let controller = popover.popoverPresentationController {
      controller.barButtonItem = sender
    }
    popover.delegate = self
    present(popover, animated: true, completion: nil)
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
    return FadeInAnimationController()
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return FadeOutAnimationController()
  }
}

// MARK: - Menu View Controller Delegate Extension
extension DetailViewController: MenuViewControllerDelegate {
  func menuViewControllerSendEmail(_: MenuViewController) {
    dismiss(animated: true) {
      guard MFMailComposeViewController.canSendMail() else { return }

      let controller = MFMailComposeViewController()
      controller.mailComposeDelegate = self
      controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
      controller.setToRecipients(["your@email-address-here.com"])
      self.present(controller, animated: true)
    }
  }
}

// MARK: - Mail Compose View Controller Delegate Extension
extension DetailViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true)
  }
}
