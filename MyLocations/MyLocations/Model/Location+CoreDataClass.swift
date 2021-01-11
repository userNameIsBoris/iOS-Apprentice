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
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }

  public var title: String? {
    if locationDescription.isEmpty {
      return "(No Description)"
    } else {
      return locationDescription
    }
  }

  public var subtitle: String? {
    return category
  }
}
