//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Борис on 08.02.2021.
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

  // MARK: - Properties
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  var date = Date()
  
  var managedObjectContext: NSManagedObjectContext!

  // MARK: - Outlets
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  // MARK: - Actions
  @IBAction func done(_ sender: UIBarButtonItem) {
    guard let mainView = navigationController?.parent?.view else { return }

    // Show HUD
    let hudView = HudView.hud(inView: mainView, animated: true)
    hudView.text = "Tagged"

    // Create a new location instance and set properties
    let location = Location(context: managedObjectContext)

    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.date = date
    location.category = categoryName
    location.placemark = placemark
    location.locationDescription = descriptionTextView.text

    do {
      try managedObjectContext.save()

      // Hide HUD and pop VC
      afterDelay(0.6) {
        hudView.hide(animated: true)
        afterDelay(0.3) {
          self.navigationController?.popViewController(animated: true)
        }
      }
    } catch {
      fatalCoreDataError(error)
    }
  }

  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func categoryPickerDidPickedCategory(_ segue: UIStoryboardSegue) {
    let controller = segue.source as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()

    descriptionTextView.text = ""
    categoryLabel.text = categoryName

    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    if let placemark = placemark {
      addressLabel.text = string(from: placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    dateLabel.text = dateFormat(date: date)

    // Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName      
    }
  }

  // MARK: - Helper Methods
  func string(from placemark: CLPlacemark) -> String {
    var text = ""
    if let tmp = placemark.subThoroughfare {
      text += tmp + " "
    }
    if let tmp = placemark.thoroughfare {
      text += tmp + ", "
    }
    if let tmp = placemark.locality {
      text += tmp + ", "
    }
    if let tmp = placemark.administrativeArea {
      text += tmp + " "
    }
    if let tmp = placemark.postalCode {
      text += tmp + ", "
    }
    if let tmp = placemark.country {
      text += tmp
    }
    return text
  }

  func dateFormat(date: Date) -> String {
    dateFormatter.string(from: date)
  }

  @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)

    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0  {
      return
    }
    descriptionTextView.resignFirstResponder()
  }

  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 || indexPath.section == 1 ? indexPath : nil
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    }
  }
}
