//
//  EvaluationData+CoreDataProperties.swift
//  Health
//
//  Created by Yalin on 15/10/14.
//  Copyright © 2015年 Yalin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension EvaluationData {

    @NSManaged var bmi: NSNumber?
    @NSManaged var bmiMax: NSNumber?
    @NSManaged var bmiMin: NSNumber?
    @NSManaged var bmr: NSNumber?
    @NSManaged var bodyAge: NSNumber?
    @NSManaged var boneMuscleWeight: NSNumber?
    @NSManaged var boneMuscleWeightMax: NSNumber?
    @NSManaged var boneMuscleWeightMin: NSNumber?
    @NSManaged var boneWeight: NSNumber?
    @NSManaged var boneWeightMax: NSNumber?
    @NSManaged var boneWeightMin: NSNumber?
    @NSManaged var dataId: String?
    @NSManaged var fatControl: NSNumber?
    @NSManaged var fatFreeBodyWeight: NSNumber?
    @NSManaged var fatFreeBodyWeightMax: NSNumber?
    @NSManaged var fatFreeBodyWeightMin: NSNumber?
    @NSManaged var fatPercentage: NSNumber?
    @NSManaged var fatPercentageMax: NSNumber?
    @NSManaged var fatPercentageMin: NSNumber?
    @NSManaged var fatWeight: NSNumber?
    @NSManaged var fatWeightMax: NSNumber?
    @NSManaged var fatWeightMin: NSNumber?
    @NSManaged var goalWeight: NSNumber?
    @NSManaged var hepaticAdiposeInfiltration: NSNumber?
    @NSManaged var isUpload: NSNumber?
    @NSManaged var leftLowerExtremityBone: NSNumber?
    @NSManaged var leftLowerExtremityFat: NSNumber?
    @NSManaged var leftLowerExtremityMuscle: NSNumber?
    @NSManaged var leftUpperExtremityBone: NSNumber?
    @NSManaged var leftUpperExtremityFat: NSNumber?
    @NSManaged var leftUpperExtremityMuscle: NSNumber?
    @NSManaged var m_smm: NSNumber?
    @NSManaged var muscleControl: NSNumber?
    @NSManaged var muscleWeight: NSNumber?
    @NSManaged var muscleWeightMax: NSNumber?
    @NSManaged var muscleWeightMin: NSNumber?
    @NSManaged var proteinWeight: NSNumber?
    @NSManaged var proteinWeightMax: NSNumber?
    @NSManaged var proteinWeightMin: NSNumber?
    @NSManaged var rightLowerExtremityBone: NSNumber?
    @NSManaged var rightLowerExtremityFat: NSNumber?
    @NSManaged var rightLowerExtremityMuscle: NSNumber?
    @NSManaged var rightUpperExtremityBone: NSNumber?
    @NSManaged var rightUpperExtremityFat: NSNumber?
    @NSManaged var rightUpperExtremityMuscle: NSNumber?
    @NSManaged var score: NSNumber?
    @NSManaged var sw: NSNumber?
    @NSManaged var swMax: NSNumber?
    @NSManaged var swMin: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var trunkLimbBone: NSNumber?
    @NSManaged var trunkLimbFat: NSNumber?
    @NSManaged var trunkLimbMuscle: NSNumber?
    @NSManaged var userId: NSNumber?
    @NSManaged var visceralFatPercentage: NSNumber?
    @NSManaged var waterPercentage: NSNumber?
    @NSManaged var waterWeight: NSNumber?
    @NSManaged var waterWeightMax: NSNumber?
    @NSManaged var waterWeightMin: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var weightControl: NSNumber?
    @NSManaged var whr: NSNumber?
    @NSManaged var whrMax: NSNumber?
    @NSManaged var whrMin: NSNumber?

}
