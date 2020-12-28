//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Борис on 27.12.2020.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

class LocationDetailsViewController: UITableViewController {
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudelabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"

  override func viewDidLoad() {
    super.viewDidLoad()
    descriptionTextView.text = ""
    categoryLabel.text = categoryName
    categoryLabel.text = categoryName
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudelabel.text = String(format: "%.8f", coordinate.longitude)

    if let placemark = placemark {
      addressLabel.text = string(from: placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    dateLabel.text = format(date: Date())
  }

// MARK: - Actions
  @IBAction func done() {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
    let controller = segue.source as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }

  // MARK:- Helper Methods
  func string(from placemark: CLPlacemark) -> String {
    var text = ""

    if let subThoroughfare = placemark.subThoroughfare {
      text += subThoroughfare + " "
    }
    if let thoroughfare = placemark.thoroughfare {
      text += thoroughfare + ", "
    }
    if let locality = placemark.locality {
      text += locality + ", "
    }
    if let administrativeArea = placemark.administrativeArea {
      text += administrativeArea + " "
    }
    if let postalCode = placemark.postalCode {
      text += postalCode + ", "
    }
    if let country = placemark.country {
      text += country
    }

    return text
  }

  func format(date: Date) -> String {
    dateFormatter.string(from: date)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
}
