//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Boris Ezhov on 08.02.2021.
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
  private var descriptionText = ""
  private var categoryName = "No Category"
  var image: UIImage? {
    didSet {
      if let theImage = image {
        show(image: theImage)
      }
    }
  }
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  private var date = Date()
  var managedObjectContext: NSManagedObjectContext!
  var locationToEdit: Location? {
    didSet {
      if let location = locationToEdit {
        categoryName = location.category
        coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        date = location.date
        descriptionText = location.locationDescription
        placemark = location.placemark
      }
    }
  }
  var observer: Any!

  // MARK: (De)inits
  deinit {
    print("*** Deinit \(self)")
    NotificationCenter.default.removeObserver(observer!)
  }

  // MARK: - Outlets
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var addPhotoLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  // MARK: - Actions
  @IBAction func done(_ sender: UIBarButtonItem) {
    guard let mainView = navigationController?.parent?.view else { return }

    let hudView = HudView.hud(inView: mainView, animated: true)
    let location: Location

    if let temp = locationToEdit {
      hudView.text = "Updated"
      location = temp
    } else {
      hudView.text = "Tagged"
      location = Location(context: managedObjectContext)
      location.photoID = nil
    }

    // Set location's properties
    location.locationDescription = descriptionTextView.text
    location.category = categoryName
    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.placemark = placemark
    location.date = date

    if let image = image {
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID() as NSNumber
      }
      if let data = image.jpegData(compressionQuality: 0.5) {
        do {
          try data.write(to: location.photoURL, options: .atomic)
        } catch {
          print("Error writing file")
        }
      }
    }
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

    listenForBackgroundNotification()
    if let location = locationToEdit {
      title = "Edit Location"
      if location.hasPhoto {
        if let theImage = location.photoImage {
          show(image: theImage)
        }
      }
    }
    descriptionTextView.text = descriptionText
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
  private func string(from placemark: CLPlacemark) -> String {
    var text = ""
    text.add(text: placemark.subThoroughfare)
    text.add(text: placemark.thoroughfare, separatedBy: " ")
    text.add(text: placemark.locality, separatedBy: ", ")
    text.add(text: placemark.administrativeArea, separatedBy: ", ")
    text.add(text: placemark.postalCode, separatedBy: " ")
    text.add(text: placemark.country, separatedBy: ", ")

    return text
  }

  private func dateFormat(date: Date) -> String {
    dateFormatter.string(from: date)
  }

  @objc private func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)

    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0  {
      return
    }
    descriptionTextView.resignFirstResponder()
  }

  private func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
    imageHeight.constant = 260 / (image.size.width / image.size.height)
    print(image.size.width / image.size.height)
    tableView.reloadData()
  }

  private func listenForBackgroundNotification() {
    observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
      if let weakSelf = self {
        if weakSelf.presentedViewController != nil {
          weakSelf.dismiss(animated: true)
        }
        weakSelf.descriptionTextView.resignFirstResponder()
      }
    }
  }

  // MARK: - Table View Delegates
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

// MARK: - Image Picker Controller Delegate && Navigation Controller Delegate Extension
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // MARK: - Image Helper Methods
  func pickPhoto() {
    UIImagePickerController.isSourceTypeAvailable(.camera) ? showPhotoMenu() : choosePhotoFromLibrary()
  }

  func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "Take photo", style: .default) { _ in
      self.takePhotoWithCamera()
    }
    let libraryAction = UIAlertAction(title: "Choose From Library", style: .default) { _ in
      self.choosePhotoFromLibrary()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(cameraAction)
    alert.addAction(libraryAction)
    alert.addAction(cancelAction)
    alert.view.tintColor = view.tintColor
    present(alert, animated: true)
  }

  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true)
  }

  func choosePhotoFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true)
  }

  // MARK: - Image Picker Delegates
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    dismiss(animated: true)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
  }
}
