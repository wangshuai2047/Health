//
//  EvaluationData.swift
//  Health
//
//  Created by Yalin on 15/8/29.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(EvaluationData)
class EvaluationData: NSManagedObject {

    @NSManaged var dataId: String
    @NSManaged var isUpload: NSNumber
    @NSManaged var timeStamp: NSDate
    @NSManaged var userId: NSNumber
    @NSManaged var weight: NSNumber
    @NSManaged var waterPercentage: NSNumber
    @NSManaged var visceralFatPercentage: NSNumber
    @NSManaged var fatPercentage: NSNumber
    @NSManaged var fatWeight: NSNumber
    @NSManaged var waterWeight: NSNumber
    @NSManaged var muscleWeight: NSNumber
    @NSManaged var proteinWeight: NSNumber
    @NSManaged var boneWeight: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
