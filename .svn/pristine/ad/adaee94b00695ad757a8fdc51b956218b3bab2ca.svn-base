//
//  UserDBData.swift
//  Health
//
//  Created by Yalin on 15/9/11.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(UserDBData)
class UserDBData: NSManagedObject {

    @NSManaged var age: NSNumber
    @NSManaged var gender: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var name: String
    @NSManaged var userId: NSNumber
    @NSManaged var headURL: String

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }
}
