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

    @NSManaged var boneMuscleWeight: NSNumber?
    @NSManaged var boneWeight: NSNumber?
    @NSManaged var dataId: String?
    @NSManaged var fatPercentage: NSNumber?
    @NSManaged var fatWeight: NSNumber?
    @NSManaged var isUpload: NSNumber?
    @NSManaged var muscleWeight: NSNumber?
    @NSManaged var proteinWeight: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var userId: NSNumber?
    @NSManaged var visceralFatPercentage: NSNumber?
    @NSManaged var waterPercentage: NSNumber?
    @NSManaged var waterWeight: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var hepaticAdiposeInfiltration: NSNumber?
    @NSManaged var fatFreeBodyWeight: NSNumber?
    @NSManaged var fatFreeBodyWeightMin: NSNumber?
    @NSManaged var fatFreeBodyWeightMax: NSNumber?
    @NSManaged var muscleWeightMin: NSNumber?
    @NSManaged var muscleWeightMax: NSNumber?
    @NSManaged var proteinWeightMin: NSNumber?
    @NSManaged var proteinWeightMax: NSNumber?
    @NSManaged var boneWeightMin: NSNumber?
    @NSManaged var boneWeightMax: NSNumber?
    @NSManaged var waterWeightMin: NSNumber?
    @NSManaged var waterWeightMax: NSNumber?
    @NSManaged var fatWeightMin: NSNumber?
    @NSManaged var fatWeightMax: NSNumber?
    @NSManaged var fatPercentageMin: NSNumber?
    @NSManaged var fatPercentageMax: NSNumber?
    @NSManaged var whr: NSNumber?
    @NSManaged var whrMin: NSNumber?
    @NSManaged var whrMax: NSNumber?
    @NSManaged var bmi: NSNumber?
    @NSManaged var bmiMin: NSNumber?
    @NSManaged var bmiMax: NSNumber?
    @NSManaged var bmr: NSNumber?
    @NSManaged var bodyAge: NSNumber?
    @NSManaged var boneMuscleWeightMin: NSNumber?
    @NSManaged var boneMuscleWeightMax: NSNumber?
    @NSManaged var muscleControl: NSNumber?
    @NSManaged var fatControl: NSNumber?
    @NSManaged var weightControl: NSNumber?
    @NSManaged var sw: NSNumber?
    @NSManaged var swMin: NSNumber?
    @NSManaged var swMax: NSNumber?
    @NSManaged var goalWeight: NSNumber?
    @NSManaged var m_smm: NSNumber?
    @NSManaged var rightUpperExtremityFat: NSNumber?
    @NSManaged var rightUpperExtremityMuscle: NSNumber?
    @NSManaged var rightUpperExtremityBone: NSNumber?
    @NSManaged var leftUpperExtremityFat: NSNumber?
    @NSManaged var leftUpperExtremityMuscle: NSNumber?
    @NSManaged var leftUpperExtremityBone: NSNumber?
    @NSManaged var trunkLimbFat: NSNumber?
    @NSManaged var trunkLimbMuscle: NSNumber?
    @NSManaged var trunkLimbBone: NSNumber?
    @NSManaged var rightLowerExtremityFat: NSNumber?
    @NSManaged var rightLowerExtremityMuscle: NSNumber?
    @NSManaged var rightLowerExtremityBone: NSNumber?
    @NSManaged var leftLowerExtremityFat: NSNumber?
    @NSManaged var leftLowerExtremityMuscle: NSNumber?
    @NSManaged var leftLowerExtremityBone: NSNumber?
    @NSManaged var score: NSNumber?

}
