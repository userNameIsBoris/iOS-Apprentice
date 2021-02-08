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

  // Location
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: Error?

  // Reverse geocoding
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: Error?

  // Other
  var timer: Timer?

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
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

    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      placemark = nil
      lastGeocodingError = nil
      startLocationManager()
    }
    updateLabels()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "TagLocation" {
      let controller = segue.destination as! LocationDetailsViewController
      controller.coordinate = location!.coordinate
      controller.placemark = placemark
    }
  }

  // MARK: - Helper Methods
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true

      timer = Timer.scheduledTimer(
        timeInterval: 60,
        target: self,
        selector: #selector(didTimeOut),
        userInfo: nil,
        repeats: false)
    }
  }

  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false

      timer?.invalidate()
    }
  }

  @objc func didTimeOut() {
    print("*** Timeout")
    if location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyErrorDomain", code: 1)
      updateLabels()
    }
  }

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
      messageLabel.text = ""
      tagButton.isHidden = false

      // Configure addressLabel
      if let placemark = placemark {
        addressLabel.text = string(from: placemark)
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
      } else if lastGeocodingError != nil {
        addressLabel.text = "Error Finding Address"
      } else {
        addressLabel.text = "No address found"
      }

    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.isHidden = true

      // Configure messageLabel
      let statusMessage: String

      if let error = lastLocationError as NSError? {
        if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Locaiton"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if updatingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
    }
    configureGetButton()
  }

  func configureGetButton() {
    getButton.setTitle(updatingLocation ? "Stop" : "Get My Location", for: .normal)
  }

  func string(from placemark: CLPlacemark) -> String {
    var line1 = ""
    var line2 = ""

    if let subThoroughfare = placemark.subThoroughfare {
      line1 += subThoroughfare + " "
    }
    if let thoroughfare = placemark.thoroughfare {
      line1 += thoroughfare
    }
    if let locality = placemark.locality {
      line2 += locality + " "
    }
    if let administrativeArea = placemark.administrativeArea {
      line2 += administrativeArea + " "
    }
    if let postalCode = placemark.postalCode {
      line2 += postalCode
    }
    return line1 + "\n" + line2
  }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {

  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError: \(error.localizedDescription)")

    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
    updateLabels()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations: \(newLocation)")

    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }

    if newLocation.horizontalAccuracy < 0 {
      return
    }

    var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
    if let location = location {
      distance = newLocation.distance(from: location)
    }

    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation

      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("*** Done")
        stopLocationManager()

        if distance > 0 {
          performingReverseGeocoding = false
        }
      }
      updateLabels()

      // Reverse geocoding
      if !performingReverseGeocoding {
        print("Starting reverse geocode")
        performingReverseGeocoding = true

        geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
          self.lastGeocodingError = error

          if error == nil, let places = placemarks, !places.isEmpty {
            self.placemark = places.last!
          } else {
            self.placemark = nil
          }

          self.performingReverseGeocoding = false
          self.updateLabels()
        }
      }

    } else if distance < 1 {
      let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
      if timeInterval > 10 {
        print("*** Force done")
        stopLocationManager()
        updateLabels()
      }
    }
  }
}
