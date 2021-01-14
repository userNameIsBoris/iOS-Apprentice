//
//  LocationCell.swift
//  MyLocations
//
//  Created by Борис on 07.01.2021.
//

import UIKit

class LocationCell: UITableViewCell {
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()

    // Rounded corners for images
    photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
    photoImageView.clipsToBounds = true
    separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  // MARK: - Helper Methods
  func configure(for location: Location) {

    // Image
    photoImageView.image = thumbnail(for: location)

    // Description
    descriptionLabel.text = location.locationDescription.isEmpty ? "(No description)" : location.locationDescription

    // Address
    
    if let placemark = location.placemark {
      var text = ""
      text.add(text: placemark.subThoroughfare)
      text.add(text: placemark.thoroughfare, separatedBy: " ")
      text.add(text: placemark.locality, separatedBy: ", ")

      addressLabel.text = text
    } else {
      addressLabel.text = String(format: "Lat: %.8f, long: %.8f", location.latitude, location.longitude)
    }
  }

  func thumbnail(for location: Location) -> UIImage {
    if location.hasPhoto, let image = location.image {
      return image.resized(withBounds: CGSize(width: 52, height: 52))
    }
    return UIImage(named: "No Photo")!
  }
}
