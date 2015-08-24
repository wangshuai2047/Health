//
//  EvaluationData.swift
//  Health
//
//  Created by Yalin on 15/8/24.
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
    @NSManaged var fatContent: NSNumber
    @NSManaged var waterContent: NSNumber
    @NSManaged var boneContent: NSNumber
    @NSManaged var muscleContent: NSNumber
    @NSManaged var visceralFatContent: NSNumber
    @NSManaged var calorie: NSNumber
    @NSManaged var bmi: NSNumber

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}
