//
//  EvaluationData.swift
//  Health
//
//  Created by Yalin on 15/9/9.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(EvaluationData)
class EvaluationData: NSManagedObject {

    @NSManaged var boneMuscleWeight: NSNumber
    @NSManaged var boneWeight: NSNumber
    @NSManaged var dataId: String
    @NSManaged var fatPercentage: NSNumber
    @NSManaged var fatWeight: NSNumber
    @NSManaged var isUpload: NSNumber
    @NSManaged var muscleWeight: NSNumber
    @NSManaged var proteinWeight: NSNumber
    @NSManaged var timeStamp: NSDate
    @NSManaged var userId: NSNumber
    @NSManaged var visceralFatPercentage: NSNumber
    @NSManaged var waterPercentage: NSNumber
    @NSManaged var waterWeight: NSNumber
    @NSManaged var weight: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
