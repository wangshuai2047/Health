//
//  GoalData.swift
//  Health
//
//  Created by Yalin on 15/8/15.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

class GoalData: NSManagedObject {

    @NSManaged var awakeCount: NSNumber
    @NSManaged var awakeTime: NSNumber
    @NSManaged var dataId: String
    @NSManaged var deepSleep: NSNumber
    @NSManaged var eyesCount: NSNumber
    @NSManaged var isUpload: NSNumber
    @NSManaged var lightlySleep: NSNumber
    @NSManaged var sleepTime: NSNumber
    @NSManaged var steps: NSNumber
    @NSManaged var timescamp: NSDate
    @NSManaged var userId: String

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
