//
//  UserDBData.swift
//  Health
//
//  Created by Yalin on 15/9/2.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(UserDBData)
class UserDBData: NSManagedObject {

    @NSManaged var age: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var userId: NSNumber
    @NSManaged var name: String
    @NSManaged var gender: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
