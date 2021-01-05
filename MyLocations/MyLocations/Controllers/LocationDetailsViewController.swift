//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Борис on 27.12.2020.
//

import UIKit
import CoreLocation
import CoreData

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
  var date = Date()
  var managedObjectContext: NSManagedObjectContext!

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
    dateLabel.text = format(date: date)

    // Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }

// MARK: - Actions
  @IBAction func done() {
    let hudView = HudView.hud(inView: navigationController!.view, animated: true)
    hudView.text = "Tagged"

    let location = Location(context: managedObjectContext)
    location.locationDescription = descriptionTextView.text
    location.category = categoryName
    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark

    do {
      try managedObjectContext.save()
      afterDelay(0.6, run: {
        hudView.hide()
        self.navigationController?.popViewController(animated: true)
      })
    } catch {
      fatalCoreDataError(error)
    }
    
    let delayInSeconds = 0.6
    afterDelay(delayInSeconds) {
      hudView.hide()
      self.navigationController?.popViewController(animated: true)
    }
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

  @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
      return
    }
    descriptionTextView.resignFirstResponder()
  }

  //MARK: Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 || indexPath.section == 1 ? indexPath : nil
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
}
