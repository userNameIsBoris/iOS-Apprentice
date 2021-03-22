//
//  AboutViewController.swift
//  Bullseye
//
//  Created by Boris Ezhov on 20.12.2020.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
  @IBOutlet weak var webView: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    webView.scrollView.layer.cornerRadius = 10
    guard let url = Bundle.main.url(forResource: "Bullseye", withExtension: "html") else { return }
    let request = URLRequest(url: url)
    webView.load(request)
  }

  // MARK: - Actions
  @IBAction func close(_ sender: UIButton) {
    dismiss(animated: true)
  }
}
