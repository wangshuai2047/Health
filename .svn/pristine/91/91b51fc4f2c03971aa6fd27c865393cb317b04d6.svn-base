//
//  GoalData.swift
//  Health
//
//  Created by Yalin on 15/9/6.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(GoalData)
class GoalData: NSManagedObject {

    @NSManaged var dataId: String
    @NSManaged var isUpload: NSNumber
    @NSManaged var steps: NSNumber
    @NSManaged var startTime: Date
    @NSManaged var userId: NSNumber
    @NSManaged var endTime: Date
    @NSManaged var stepsType: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }
}
