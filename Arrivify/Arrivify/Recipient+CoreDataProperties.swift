//
//  Recipient+CoreDataProperties.swift
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

extension Recipient {

    @NSManaged var name: String?
    @NSManaged var phone: String?

}
