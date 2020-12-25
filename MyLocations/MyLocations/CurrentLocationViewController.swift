//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Борис on 25.12.2020.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var adressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!

  let locationManager = CLLocationManager()
  var location: CLLocation?

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }

  // MARK: - Actions
  @IBAction func getLocation() {
    let authStatus = locationManager.authorizationStatus

    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }

    if authStatus == .denied || authStatus == .restricted {
      showLocationAccessDeniedAlert()
    }

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
  }

  // MARK: - Helper Methods
  func showLocationAccessDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)

    present(alert, animated: true, completion: nil)
  }

  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.isHidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      tagButton.isHidden = true
      messageLabel.text = "Tap 'Get My Location' to Start"
    }
  }

  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")

    location = newLocation
    updateLabels()
  }
}

