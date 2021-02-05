//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Борис on 05.01.2021.
//
//

import Foundation
import MapKit
import CoreData

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
  var hasPhoto: Bool {
    return photoID != nil
  }
  var photoURL: URL {
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.intValue).jpg"
    return applicationDocumentDirectory.appendingPathComponent(filename)
  }

  var image: UIImage? {
    return UIImage(contentsOfFile: photoURL.path)
  }

  func removePhotoFile() {
    if hasPhoto {
      do {
        try FileManager.default.removeItem(at: photoURL)
      } catch {
        print("Error removing photo file: \(error)")
      }
    }
  }
  class func nextPhotoID() -> Int {
    let userDefaults = UserDefaults.standard
    let currentID = userDefaults.integer(forKey: "PhotoID") + 1
    userDefaults.set(currentID, forKey: "PhotoID")
    return currentID    
  }

  // Conformity to protocol 'MKAnnotation'
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  public var title: String? {
    return locationDescription.isEmpty ? "(No Description)" : locationDescription
  }
  public var subtitle: String? {
    return category
  }
}
