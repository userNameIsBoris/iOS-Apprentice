//
//  MapViewController.swift
//  MyLocations
//
//  Created by Boris Ezhov on 15.02.2021.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!

  var locations: [Location] = []
  var managedObjectContext: NSManagedObjectContext! {
    didSet {
      NotificationCenter.default.addObserver(
        forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
        object: managedObjectContext, queue: .main) { _ in
        if self.isViewLoaded {
          self.updateLocations()
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLocations()

    if !locations.isEmpty {
      showLocations()
    }
  }

  // MARK: - Actions
  @IBAction func showUser() {
    let region = regionForUserLocation()
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }

  @IBAction func showLocations() {
    let theRegion = region(for: locations)
    mapView.setRegion(theRegion, animated: true)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditLocation" {
      let controller = segue.destination as! LocationDetailsViewController
      let button = sender as! UIButton
      let location = locations[button.tag]

      controller.locationToEdit = location
      controller.managedObjectContext = managedObjectContext
    }
  }

  // MARK: - Helper Methods
  private func updateLocations() {
    mapView.removeAnnotations(locations)

    let fetchRequest = NSFetchRequest<Location>()
    let entity = Location.entity()
    fetchRequest.entity = entity

    locations = try! managedObjectContext.fetch(fetchRequest)
    mapView.addAnnotations(locations)
  }

  func regionForUserLocation() -> MKCoordinateRegion {
    let region = MKCoordinateRegion(
      center: mapView.userLocation.coordinate,
      latitudinalMeters: 1000,
      longitudinalMeters: 1000)
    return region
  }

  func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
    let region: MKCoordinateRegion

    switch annotations.count {
    case 0:
      region = regionForUserLocation()

    case 1:
      let annotation = annotations[annotations.count - 1]
      region = MKCoordinateRegion(
        center: annotation.coordinate,
        latitudinalMeters: 1000,
        longitudinalMeters: 1000)

    default:
      var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

      for annotation in annotations {
        topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
        topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
        bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
        bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
      }

      let center = CLLocationCoordinate2D(
        latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
        longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

      let extraSpace = 1.3
      let span = MKCoordinateSpan(
        latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
        longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

      region = MKCoordinateRegion(center: center, span: span)
    }
    return mapView.regionThatFits(region)
  }

  @objc func showLocationDetails(_ sender: UIButton) {
    performSegue(withIdentifier: "EditLocation", sender: sender)
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is Location else { return nil }

    let identifier = "Location"

    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      if annotationView == nil {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.isEnabled = true
        pinView.canShowCallout = true
        pinView.animatesDrop = false
        pinView.pinTintColor = UIColor(
          red: 255 / 255,
          green: 238 / 255,
          blue: 136 / 255,
          alpha: 1)

        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
        pinView.rightCalloutAccessoryView = rightButton
        annotationView = pinView
      }

    if let annotationView = annotationView {
      annotationView.annotation = annotation
      let button = annotationView.rightCalloutAccessoryView as! UIButton
      if let index = locations.firstIndex(of: annotation as! Location) {
        button.tag = index
      }
    }
    return annotationView
  }
}
