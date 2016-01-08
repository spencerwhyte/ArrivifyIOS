//
//  Notification+CoreDataProperties.swift
//  Arrivify
//
//  Created by Spencer Whyte on 2016-01-04.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Notification {

    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var image: NSData?
    @NSManaged var locationName: String?
    @NSManaged var message: String?
    @NSManaged var radius: Int32
    @NSManaged var geofenceType: String?
    @NSManaged var recipients: NSSet?

}
