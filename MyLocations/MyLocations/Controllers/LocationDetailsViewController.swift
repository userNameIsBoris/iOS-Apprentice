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
  @IBOutlet weak var addPhotoLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageHeight: NSLayoutConstraint!

  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  var date = Date()
  var managedObjectContext: NSManagedObjectContext!
  var descriptionText = ""
  var locationToEdit: Location? {
    didSet {
      if let location = locationToEdit {
        descriptionText = location.locationDescription
        categoryName = location.category
        date = location.date
        coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        placemark = location.placemark
      }
    }
  }
  var image: UIImage? {
    didSet {
      if let theImage = self.image {
        self.show(image: theImage)
      }
    }
  }
  var observer: Any!

  deinit {
    print("*** deinit \(self)")
    NotificationCenter.default.removeObserver(observer!)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    listenForBackgroundNotification()
    if let location = locationToEdit {
      title = "Edit Location"
      if location.hasPhoto {
        if let theImage = location.image {
          show(image: theImage)
        }
      }
    }
    descriptionTextView.text = descriptionText
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

    let location: Location
    if let temp = locationToEdit {
      hudView.text = "Updated"
      location = temp
    } else {
      hudView.text = "Tagged"
      location = Location(context: managedObjectContext)
      location.photoID = nil
    }

    location.locationDescription = descriptionTextView.text
    location.category = categoryName
    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark

    // Save image
    if let image = image {
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID() as NSNumber
      }
    }

    if let data = image?.jpegData(compressionQuality: 0) {
      do {
        try data.write(to: location.photoURL, options: .atomic)
      } catch {
        print("Error writing file: \(error)")
      }
    }

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

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
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

  func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
    imageHeight.constant = 260
    tableView.reloadData()
  }

  func listenForBackgroundNotification() {
    observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
      if let weakSelf = self {
        if weakSelf.presentedViewController != nil {
          weakSelf.dismiss(animated: true, completion: nil)
        }
        weakSelf.descriptionTextView.resignFirstResponder()
      }
    }
  }

  //MARK: Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 || indexPath.section == 1 ? indexPath : nil
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    } else if indexPath.section == 1 && indexPath.row == 0 {
      tableView.deselectRow(at: indexPath, animated: true)
      pickPhoto()
    }
  }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // MARK: - Image Helper Methods
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true, completion: nil)
  }

  func choosePhotoFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true, completion: nil)
  }

  func pickPhoto() {
    UIImagePickerController.isSourceTypeAvailable(.camera) ? showPhotoMenu() : choosePhotoFromLibrary()
  }

  func showPhotoMenu() {
    let alert = UIAlertController(title: "Photo menu", message: "", preferredStyle: .actionSheet)

    let actCamera = UIAlertAction(title: "Take photo", style: .default) { _ in
      self.takePhotoWithCamera()
    }
    alert.addAction(actCamera)

    let actLibrary = UIAlertAction(title: "Choose from library", style: .default) { _ in
      self.choosePhotoFromLibrary()
    }
    alert.addAction(actLibrary)

    let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(actCancel)

    present(alert, animated: true, completion: nil)
  }

  // MARK: Image Picker Delegates
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    self.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    dismiss(animated: true, completion: nil)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}
