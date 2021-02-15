//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Борис on 12.02.2021.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject {

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
