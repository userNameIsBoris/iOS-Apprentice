//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Борис on 05.01.2021.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
      return NSFetchRequest<Location>(entityName: "Location")
  }

  @NSManaged public var latitude: Double
  @NSManaged public var longitude: Double
  @NSManaged public var placemark: CLPlacemark?
  @NSManaged public var date: Date
  @NSManaged public var locationDescription: String
  @NSManaged public var photoID: NSNumber?
  @NSManaged public var category: String
}

extension Location : Identifiable {

}
