//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Boris Ezhov on 05.02.2021.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationViewController: UIViewController {
  // MARK: - Properties
  // Location
  private let locationManager = CLLocationManager()
  private var location: CLLocation?
  private var updatingLocation = false
  private var lastLocationError: Error?

  // Reverse geocoding
  private let geocoder = CLGeocoder()
  private var placemark: CLPlacemark?
  private var performingReverseGeocoding = false
  private var lastGeocodingError: Error?

  // Core Data
  var managedObjectContext: NSManagedObjectContext!

  // Logo Animation
  private var logoIsVisible = false
  lazy private var logoButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
    button.sizeToFit()
    button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
    button.center.x = self.view.bounds.midX
    button.center.y = 220
    return button
  }()

  // Other
  private var timer: Timer?
  private var soundID: SystemSoundID = 0

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    loadSoundEffect("Sound.caf")
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
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeTextLabel: UILabel!
  @IBOutlet weak var longitudeTextLabel: UILabel!
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

    if logoIsVisible {
      hideLogoView()
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
      controller.managedObjectContext = managedObjectContext
    }
  }

  // MARK: - Helper Methods
  private func startLocationManager() {
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

  private func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
      timer?.invalidate()
    }
  }

  private func showLogoView() {
    guard !logoIsVisible else { return }
    containerView.isHidden = true
    logoIsVisible = true
    containerView.center.x = view.bounds.size.width * 2
    containerView.center.y = 40 + view.bounds.size.height / 2
    let centerX = view.bounds.midX

    // Hide containerView animation
    let panelMover = CABasicAnimation(keyPath: "position")
    panelMover.isRemovedOnCompletion = false
    panelMover.fillMode = CAMediaTimingFillMode.forwards
    panelMover.duration = 0.5
    panelMover.fromValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
    panelMover.toValue = NSValue(cgPoint: containerView.center)
    panelMover.timingFunction = CAMediaTimingFunction(name: .easeIn)
    containerView.layer.add(panelMover, forKey: "panelMover")

    // Show logoButton animation
    let logoMover = CABasicAnimation(keyPath: "position")
    logoMover.isRemovedOnCompletion = false
    logoMover.fillMode = CAMediaTimingFillMode.forwards
    logoMover.duration = 0.6
    logoMover.fromValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
    logoMover.toValue = NSValue(cgPoint: logoButton.center)
    logoMover.timingFunction = CAMediaTimingFunction(name: .easeOut)
    logoButton.layer.add(logoMover, forKey: "logoMover")

    // Rotate logoButton animation
    let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
    logoRotator.isRemovedOnCompletion = false
    logoRotator.fillMode = CAMediaTimingFillMode.forwards
    logoRotator.duration = 0.6
    logoRotator.fromValue = 0.0
    logoRotator.toValue = 2 * Double.pi
    logoRotator.timingFunction = CAMediaTimingFunction(name: .easeOut)
    logoButton.layer.add(logoRotator, forKey: "logoRotator")
  
    view.addSubview(logoButton)
  }

  private func hideLogoView() {
    guard logoIsVisible else { return }
    logoIsVisible = false
    containerView.isHidden = false
    containerView.center.x = view.bounds.size.width * 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    let centerX = view.bounds.midX

    // Show containerView animation
    let panelMover = CABasicAnimation(keyPath: "position")
    panelMover.isRemovedOnCompletion = false
    panelMover.fillMode = CAMediaTimingFillMode.forwards
    panelMover.duration = 0.6
    panelMover.fromValue = NSValue(cgPoint: containerView.center)
    panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
    panelMover.timingFunction = CAMediaTimingFunction(name: .easeOut)
    panelMover.delegate = self
    containerView.layer.add(panelMover, forKey: "panelMover")

    // Hide logoButton animation
    let logoMover = CABasicAnimation(keyPath: "position")
    logoMover.isRemovedOnCompletion = false
    logoMover.fillMode = CAMediaTimingFillMode.forwards
    logoMover.duration = 0.5
    logoMover.fromValue = NSValue(cgPoint: logoButton.center)
    logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
    logoMover.timingFunction = CAMediaTimingFunction(name: .easeIn)
    logoButton.layer.add(logoMover, forKey: "logoMover")

    // Rotate logoButton animation
    let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
    logoRotator.isRemovedOnCompletion = false
    logoRotator.fillMode = CAMediaTimingFillMode.forwards
    logoRotator.duration = 0.5
    logoRotator.fromValue = 0.0
    logoRotator.toValue = -2 * Double.pi
    logoRotator.timingFunction = CAMediaTimingFunction(name: .easeIn)
    logoButton.layer.add(logoRotator, forKey: "logoRotator")
  }

  @objc private func didTimeOut() {
    print("*** Timeout")
    if location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyErrorDomain", code: 1)
      updateLabels()
    }
  }

  private func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Denied", message: "Please, enable location services for this app in Settings", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)

    present(alert, animated: true)
  }

  private func updateLabels() {
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
      latitudeTextLabel.isHidden = false
      longitudeTextLabel.isHidden = false
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
        statusMessage = ""
        showLogoView()
      }
      messageLabel.text = statusMessage
      latitudeTextLabel.isHidden = true
      longitudeTextLabel.isHidden = true
    }
    configureGetButton()
  }

  private func configureGetButton() {
    let spinnerTag = 1000

    if updatingLocation {
      getButton.setTitle("Stop", for: .normal)

      if view.viewWithTag(spinnerTag) == nil {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = messageLabel.center
        spinner.center.y += spinner.bounds.size.height / 2 + 25
        spinner.startAnimating()
        spinner.tag = spinnerTag
        containerView.addSubview(spinner)
      }
    } else {
      getButton.setTitle("Get My Location", for: .normal)
      if let spinner = view.viewWithTag(spinnerTag) {
        spinner.removeFromSuperview()
      }
    }
  }

  private func string(from placemark: CLPlacemark) -> String {
    var line1 = ""
    line1.add(text: placemark.subThoroughfare)
    line1.add(text: placemark.thoroughfare, separatedBy: " ")

    var line2 = ""
    line2.add(text: placemark.locality)
    line2.add(text: placemark.administrativeArea, separatedBy: " ")
    line2.add(text: placemark.postalCode, separatedBy: " ")

    line1.add(text: line2, separatedBy: "\n")
    return line1
  }

  // MARK: - Sound Effects
  private func loadSoundEffect(_ name: String) {
    guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
    let fileURL = URL(fileURLWithPath: path, isDirectory: false)
    let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
    if error != kAudioServicesNoError {
      print("Error code \(error) loading sound: \(path)")
    }
  }

  private func unloadSoundEffect() {
    AudioServicesDisposeSystemSoundID(soundID)
    soundID = 0
  }

  private func playSoundEffect() {
    AudioServicesPlaySystemSound(soundID)
  }
}

// MARK: - CLLocationManager Delegate Extension
extension CurrentLocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError: \(error.localizedDescription)")

    guard (error as NSError).code != CLError.locationUnknown.rawValue else { return }
    lastLocationError = error
    stopLocationManager()
    updateLabels()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if self.placemark != nil {
      self.playSoundEffect()
    }

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

// MARK: CAAnimation Delegate Extension
extension CurrentLocationViewController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    containerView.layer.removeAllAnimations()
    containerView.center.x = view.bounds.size.width / 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    logoButton.layer.removeAllAnimations()
    logoButton.removeFromSuperview()
  }
}
