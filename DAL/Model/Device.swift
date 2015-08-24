//
//  Device.swift
//  Health
//
//  Created by Yalin on 15/8/22.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(Device)
class Device: NSManagedObject {

    @NSManaged var uuid: String
    @NSManaged var name: String
    @NSManaged var type: NSNumber   // 0 是秤 1是手环

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
