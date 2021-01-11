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

  // MARK: - Helper Methods
  func configure(for location: Location) {
    descriptionLabel.text = location.locationDescription.isEmpty ? "(No description)" : location.locationDescription

    if let placemark = location.placemark {
      var text = ""
      if let subThoroughfare = placemark.subThoroughfare {
        text += subThoroughfare + " "
      }
      if let thoroughfare = placemark.thoroughfare {
        text += thoroughfare + ", "
      }
      if let locality = placemark.locality {
        text += locality
      }
      addressLabel.text = text
    } else {
      addressLabel.text = String(format: "Lat: %.8f, long: %.8f", location.latitude, location.longitude)
    }
  }
}
