//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Борис on 05.02.2021.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {

  // MARK: - Properties
  let locationManager = CLLocationManager()
  var location: CLLocation?

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }

  // MARK: - Outlets
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!

  // MARK: - Actions
  @IBAction func getLocation() {
    let authStatus = locationManager.authorizationStatus

    // Request authorization
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }

    // Show an alert if authorization is denied
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
  }

  // MARK: - Helper Methods
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Denied", message: "Please, enable location services for this app in Settings", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)

    present(alert, animated: true)
  }

  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
//      addressLabel.text =
      messageLabel.text = ""
      tagButton.isHidden = false
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      messageLabel.text = "Tap 'Get My Location' to Start"
      tagButton.isHidden = true
    }
  }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {

  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations: \(newLocation)")
    location = newLocation
    updateLabels()
  }
}
