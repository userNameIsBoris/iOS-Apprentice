//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Boris Ezhov on 12.02.2021.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject {
  var hasPhoto: Bool {
    return photoID != nil
  }
  var photoURL: URL {
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.intValue).jpg"
    return applicationDocumentsFolder.appendingPathComponent(filename)
  }
  var photoImage: UIImage? {
    return UIImage(contentsOfFile: photoURL.path)
  }

  class func nextPhotoID() -> Int {
    let userDefaults = UserDefaults.standard
    let currentID = userDefaults.integer(forKey: "PhotoID") + 1
    userDefaults.set(currentID, forKey: "PhotoID")
    return currentID
  }

  func removePhotoFIle() {
    if hasPhoto {
      do {
        try FileManager.default.removeItem(at: photoURL)
      } catch {
        print("Error removing file: \(error)")
      }
    }
  }
}

extension Location: MKAnnotation {
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }

  public var title: String? {
    return locationDescription.isEmpty ? "(No description)" : locationDescription
  }

  public var subtitle: String? {
    return category
  }  
}
