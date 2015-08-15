//
//  EvaluationData.swift
//  Health
//
//  Created by Yalin on 15/8/15.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(EvaluationData)
class EvaluationData: NSManagedObject {

    @NSManaged var dataId: String
    @NSManaged var fat: NSNumber
    @NSManaged var isUpload: NSNumber
    @NSManaged var metabolize: NSNumber
    @NSManaged var muscle: NSNumber
    @NSManaged var protein: NSNumber
    @NSManaged var timeStamp: NSDate
    @NSManaged var userId: String
    @NSManaged var water: NSNumber
    @NSManaged var weight: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
