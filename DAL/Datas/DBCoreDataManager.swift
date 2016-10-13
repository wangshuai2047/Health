//
//  DBCoreDataManager.swift
//  Health
//
//  Created by Yalin on 15/8/15.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension DBManager {
    
    // MARK: - Core Data stack
    
    var applicationDocumentsDirectory: URL  {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yalin.Test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
    var managedObjectModel: NSManagedObjectModel {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Health", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(self.userId!).sqlite")
//        print("db Path: \(url)")
        
        var error: NSError? = nil
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }
    
    var managedObjectContext: NSManagedObjectContext? {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }
    
    
}

// MARK: - User Model操作
extension DBManager: DBUserProtocol {
    
    func addUser(_ setDatas: (_ setDatas: inout UserDBData) -> UserDBData) {
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObject(forEntityName: "UserDBData", into: context) as! UserDBData
        
        _ = setDatas(&insertData)
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
    }
    
    func addOrUpdateUser(_ userModel: UserModel) {
        
        if let _ = queryUser(userModel.userId) {
            // 更新
            let context = self.managedObjectContext!
            let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)
            // ResultType' could not be inferred
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "userId == %d", userModel.userId)
            
            let listData = (try! context.fetch(request)) as! [UserDBData]
            
            if listData.count > 0 {
                for i in 0...listData.count - 1 {
                    let managedObject = listData[i]
                    managedObject.name = userModel.name
                    if let headURL = userModel.headURL {
                        managedObject.headURL = headURL
                    }
                }
            }
            
            do {
                try context.save()
            }catch let error1 as NSError {
                print(error1)
            }
        }
        else {
            // 插入一个新的
            let context = self.managedObjectContext!
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "UserDBData", into: context) as! UserDBData
            
            insertData.userId = NSNumber(value: userModel.userId as Int)
            insertData.age = NSNumber(value: userModel.age as UInt8)
            insertData.height = NSNumber(value: userModel.height as UInt8)
            insertData.gender = NSNumber(value: userModel.gender as Bool)
            insertData.name = userModel.name
            if let headURL = userModel.headURL {
                insertData.headURL = headURL
            }
            
            do {
                try context.save()
                NSLog("Insert Evaluation Data Success")
            } catch _ {
                NSLog("Insert Evaluation Data Fail")
            }
        }
    }
    
    func deleteUser(_ userId: Int) {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %d", userId)
        
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            print(error1)
            listData = nil
        }
        for data in listData as! [UserDBData] {
            context.delete(data)
            do {
                try context.save()
                print("删除成功")
            } catch let error as NSError {
                print(error)
                print("删除失败")
            }
        }
    }
    
    func queryAllUser() -> [[String : AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        var datas: [[String: AnyObject]] = []
        if let listData = (try? context.fetch(request)) as? [UserDBData] {
            for managedObject in listData {
                datas += [userToDic(managedObject)]
            }
        }
        
        return datas
    }
    
    func queryUser(_ userId: Int) -> [String: AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %d", userId)
        request.fetchLimit = 1
        
        if let listData = (try? context.fetch(request)) as? [UserDBData] {
            for managedObject in listData {
                return userToDic(managedObject)
            }
        }
        
        return nil
    }
    
    func deleteAllUser() {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDBData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            print(error1)
            listData = nil
        }
        for data in listData as! [UserDBData] {
            context.delete(data)
            do {
                try context.save()
                print("删除成功")
            } catch let error as NSError {
                print(error)
                print("删除失败")
            }
        }
    }
}

// MARK: - 测量数据
extension DBManager: DBManagerProtocol {
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error as NSError {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func addEvaluationDatas(_ results: [ScaleResultProtocol], isUpload: Bool) {
        let context = self.managedObjectContext!
        
        for result in results {
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "EvaluationData", into: context) as! EvaluationData
            
            if let _ = result as? MyBodyResult {
                insertData.deviceType = 0
            }
            if let _ = result as? MyBodyMiniAndPlusResult {
                insertData.deviceType = 1
            }
            
            insertData.dataId = result.dataId
            insertData.userId = result.userId as NSNumber?
            insertData.timeStamp = result.timeStamp
            insertData.isUpload = isUpload as NSNumber?
            
            insertData.boneMuscleWeight = result.boneMuscleWeight as NSNumber?
            insertData.boneWeight = result.boneWeight as NSNumber?
            insertData.fatPercentage = result.fatPercentage as NSNumber?
            insertData.fatWeight = result.fatWeight as NSNumber?
            insertData.muscleWeight = result.muscleWeight as NSNumber?
            insertData.proteinWeight = result.proteinWeight as NSNumber?
            insertData.visceralFatPercentage = result.visceralFatPercentage as NSNumber?
            insertData.waterPercentage = result.waterPercentage as NSNumber?
            insertData.waterWeight = result.waterWeight as NSNumber?
            insertData.weight = result.weight as NSNumber?
            // 脂肪肝
            if let hepaticAdiposeInfiltration = result.hepaticAdiposeInfiltration {
                insertData.hepaticAdiposeInfiltration = hepaticAdiposeInfiltration ? 1 : 2  // 1为有  2为没有
            }
            else {
                insertData.hepaticAdiposeInfiltration = 0 // 0为不支持
            }
            insertData.fatFreeBodyWeight = result.fatFreeBodyWeight as NSNumber?
            insertData.fatFreeBodyWeightMin = result.fatFreeBodyWeightRange.0 as NSNumber?
            insertData.fatFreeBodyWeightMax = result.fatFreeBodyWeightRange.1 as NSNumber?
            insertData.muscleWeightMin = result.muscleWeightRange.0 as NSNumber?
            insertData.muscleWeightMax = result.muscleWeightRange.1 as NSNumber?
            insertData.proteinWeightMin = result.proteinWeightRange.0 as NSNumber?
            insertData.proteinWeightMax = result.proteinWeightRange.1 as NSNumber?
            insertData.boneWeightMin = result.boneWeightRange.0 as NSNumber?
            insertData.boneWeightMax = result.boneWeightRange.1 as NSNumber?
            insertData.waterWeightMin = result.waterWeightRange.0 as NSNumber?
            insertData.waterWeightMax = result.waterWeightRange.1 as NSNumber?
            insertData.fatWeightMin = result.fatWeightRange.0 as NSNumber?
            insertData.fatWeightMax = result.fatWeightRange.1 as NSNumber?
            insertData.fatPercentageMin = result.fatPercentageRange.0 as NSNumber?
            insertData.fatPercentageMax = result.fatPercentageRange.1 as NSNumber?
            insertData.whr = result.WHR as NSNumber?
            insertData.whrMin = result.WHRRange.0 as NSNumber?
            insertData.whrMax = result.WHRRange.1 as NSNumber?
            insertData.bmi = result.BMI as NSNumber?
            insertData.bmiMin = result.BMIRange.0 as NSNumber?
            insertData.bmiMax = result.BMIRange.1 as NSNumber?
            insertData.bmr = result.BMR as NSNumber?
            insertData.bodyAge = result.bodyAge as NSNumber?
            insertData.boneMuscleWeightMin = result.boneMuscleRange.0 as NSNumber?
            insertData.boneMuscleWeightMax = result.boneMuscleRange.1 as NSNumber?
            insertData.muscleControl = result.muscleControl as NSNumber?
            insertData.fatControl = result.fatControl as NSNumber?
            insertData.weightControl = result.weightControl as NSNumber?
            insertData.sw = result.SW as NSNumber?
            insertData.swMin = result.SWRange.0 as NSNumber?
            insertData.swMax = result.SWRange.1 as NSNumber?
            insertData.goalWeight = result.goalWeight as NSNumber?
            insertData.m_smm = result.m_smm as NSNumber?
            insertData.rightUpperExtremityFat = result.rightUpperExtremityFat as NSNumber?
            insertData.rightUpperExtremityMuscle = result.rightUpperExtremityMuscle as NSNumber?
            insertData.rightUpperExtremityBone = result.rightUpperExtremityBone as NSNumber?
            insertData.leftUpperExtremityFat = result.leftUpperExtremityFat as NSNumber?
            insertData.leftUpperExtremityMuscle = result.leftUpperExtremityMuscle as NSNumber?
            insertData.leftUpperExtremityBone = result.leftUpperExtremityBone as NSNumber?
            insertData.trunkLimbFat = result.trunkLimbFat as NSNumber?
            insertData.trunkLimbMuscle = result.trunkLimbMuscle as NSNumber?
            insertData.trunkLimbBone = result.trunkLimbBone as NSNumber?
            insertData.rightLowerExtremityFat = result.rightLowerExtremityFat as NSNumber?
            insertData.rightLowerExtremityMuscle = result.rightLowerExtremityMuscle as NSNumber?
            insertData.rightLowerExtremityBone = result.rightLowerExtremityBone as NSNumber?
            insertData.leftLowerExtremityFat = result.leftLowerExtremityFat as NSNumber?
            insertData.leftLowerExtremityMuscle = result.leftLowerExtremityMuscle as NSNumber?
            insertData.leftLowerExtremityBone = result.leftLowerExtremityBone as NSNumber?
            insertData.externalMoisture = result.externalMoisture as NSNumber?
            insertData.internalMoisture = result.internalMoisture as NSNumber?
            insertData.edemaFactor = result.edemaFactor as NSNumber?
            insertData.obesity = result.obesity as NSNumber?
            insertData.score = result.score as NSNumber?
            
        }
        
        do {
            try context.save()
        } catch _ {
            
        }
    }
    
    func addEvaluationData(_ result: ScaleResultProtocol) {
        let context = self.managedObjectContext!
        let insertData = NSEntityDescription.insertNewObject(forEntityName: "EvaluationData", into: context) as! EvaluationData
        
        if let _ = result as? MyBodyResult {
            insertData.deviceType = 0
        }
        if let _ = result as? MyBodyMiniAndPlusResult {
            insertData.deviceType = 1
        }
        
        insertData.dataId = result.dataId
        insertData.userId = result.userId as NSNumber?
        insertData.timeStamp = Date()
        insertData.isUpload = false
        
        insertData.boneMuscleWeight = result.boneMuscleWeight as NSNumber?
        insertData.boneWeight = result.boneWeight as NSNumber?
        insertData.fatPercentage = result.fatPercentage as NSNumber?
        insertData.fatWeight = result.fatWeight as NSNumber?
        insertData.muscleWeight = result.muscleWeight as NSNumber?
        insertData.proteinWeight = result.proteinWeight as NSNumber?
        insertData.visceralFatPercentage = result.visceralFatPercentage as NSNumber?
        insertData.waterPercentage = result.waterPercentage as NSNumber?
        insertData.waterWeight = result.waterWeight as NSNumber?
        insertData.weight = result.weight as NSNumber?
        // 脂肪肝
        if let hepaticAdiposeInfiltration = result.hepaticAdiposeInfiltration {
            insertData.hepaticAdiposeInfiltration = hepaticAdiposeInfiltration ? 1 : 2  // 1为有  2为没有
        }
        else {
            insertData.hepaticAdiposeInfiltration = 0 // 0为不支持
        }
        insertData.fatFreeBodyWeight = result.fatFreeBodyWeight as NSNumber?
        insertData.fatFreeBodyWeightMin = result.fatFreeBodyWeightRange.0 as NSNumber?
        insertData.fatFreeBodyWeightMax = result.fatFreeBodyWeightRange.1 as NSNumber?
        insertData.muscleWeightMin = result.muscleWeightRange.0 as NSNumber?
        insertData.muscleWeightMax = result.muscleWeightRange.1 as NSNumber?
        insertData.proteinWeightMin = result.proteinWeightRange.0 as NSNumber?
        insertData.proteinWeightMax = result.proteinWeightRange.1 as NSNumber?
        insertData.boneWeightMin = result.boneWeightRange.0 as NSNumber?
        insertData.boneWeightMax = result.boneWeightRange.1 as NSNumber?
        insertData.waterWeightMin = result.waterWeightRange.0 as NSNumber?
        insertData.waterWeightMax = result.waterWeightRange.1 as NSNumber?
        insertData.fatWeightMin = result.fatWeightRange.0 as NSNumber?
        insertData.fatWeightMax = result.fatWeightRange.1 as NSNumber?
        insertData.fatPercentageMin = result.fatPercentageRange.0 as NSNumber?
        insertData.fatPercentageMax = result.fatPercentageRange.1 as NSNumber?
        insertData.whr = result.WHR as NSNumber?
        insertData.whrMin = result.WHRRange.0 as NSNumber?
        insertData.whrMax = result.WHRRange.1 as NSNumber?
        insertData.bmi = result.BMI as NSNumber?
        insertData.bmiMin = result.BMIRange.0 as NSNumber?
        insertData.bmiMax = result.BMIRange.1 as NSNumber?
        insertData.bmr = result.BMR as NSNumber?
        insertData.bodyAge = result.bodyAge as NSNumber?
        insertData.boneMuscleWeightMin = result.boneMuscleRange.0 as NSNumber?
        insertData.boneMuscleWeightMax = result.boneMuscleRange.1 as NSNumber?
        insertData.muscleControl = result.muscleControl as NSNumber?
        insertData.fatControl = result.fatControl as NSNumber?
        insertData.weightControl = result.weightControl as NSNumber?
        insertData.sw = result.SW as NSNumber?
        insertData.swMin = result.SWRange.0 as NSNumber?
        insertData.swMax = result.SWRange.1 as NSNumber?
        insertData.goalWeight = result.goalWeight as NSNumber?
        insertData.m_smm = result.m_smm as NSNumber?
        insertData.rightUpperExtremityFat = result.rightUpperExtremityFat as NSNumber?
        insertData.rightUpperExtremityMuscle = result.rightUpperExtremityMuscle as NSNumber?
        insertData.rightUpperExtremityBone = result.rightUpperExtremityBone as NSNumber?
        insertData.leftUpperExtremityFat = result.leftUpperExtremityFat as NSNumber?
        insertData.leftUpperExtremityMuscle = result.leftUpperExtremityMuscle as NSNumber?
        insertData.leftUpperExtremityBone = result.leftUpperExtremityBone as NSNumber?
        insertData.trunkLimbFat = result.trunkLimbFat as NSNumber?
        insertData.trunkLimbMuscle = result.trunkLimbMuscle as NSNumber?
        insertData.trunkLimbBone = result.trunkLimbBone as NSNumber?
        insertData.rightLowerExtremityFat = result.rightLowerExtremityFat as NSNumber?
        insertData.rightLowerExtremityMuscle = result.rightLowerExtremityMuscle as NSNumber?
        insertData.rightLowerExtremityBone = result.rightLowerExtremityBone as NSNumber?
        insertData.leftLowerExtremityFat = result.leftLowerExtremityFat as NSNumber?
        insertData.leftLowerExtremityMuscle = result.leftLowerExtremityMuscle as NSNumber?
        insertData.leftLowerExtremityBone = result.leftLowerExtremityBone as NSNumber?
        insertData.externalMoisture = result.externalMoisture as NSNumber?
        insertData.internalMoisture = result.internalMoisture as NSNumber?
        insertData.edemaFactor = result.edemaFactor as NSNumber?
        insertData.obesity = result.obesity as NSNumber?
        insertData.score = result.score as NSNumber?
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
        
    }
    
    func addEvaluationData(_ setDatas:( _ setDatas: inout EvaluationData)-> EvaluationData) {
        
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObject(forEntityName: "EvaluationData", into: context) as! EvaluationData
        
        insertData.dataId = UUID().uuidString
        _ = setDatas(&insertData)
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
    }
    
    func deleteEvaluationData(_ dataId: String, userId: Int) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@ AND userId == %d", dataId, userId)
//        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
            
            print(listData)
            
        } catch let error as NSError {
            print(error)
            listData = nil
        }
        for data in listData as! [EvaluationData] {
            context.delete(data)
            do {
                try context.save()
                print("删除成功")
            } catch let error as NSError {
                print("删除失败: \(error)")
            }
        }
    }
    
    func deleteEvaluationDatas(_ date: Date) {
        let context = self.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp <= %@", date as CVarArg)
        
        var error: NSError? = nil
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        
        if let datas = listData {
            for data in datas as! [EvaluationData] {
                context.delete(data)
            }
            
            do {
                try context.save()
            } catch _ {
                
            }
        }
    }
    
    func queryEvaluationData(_ dataId: String, userId: Int) -> [String: AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@ AND userId == %d", dataId, userId)
        
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error as NSError {
            print(error)
            listData = nil
        }
        
        for data in listData as! [EvaluationData] {
            return convertModel(data)
        }
        
        return nil
    }
    
    func queryEvaluationDatas(_ beginTimescamp: Date, endTimescamp: Date, userId: Int) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp <= %@ AND userId == %d", beginTimescamp as CVarArg, endTimescamp as CVarArg, userId)
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        let listData = (try! context.fetch(request)) as! [EvaluationData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func queryCountEvaluationDatas(_ beginTimescamp: Date, endTimescamp: Date, userId: Int, count: Int) -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp <= %@ AND userId == %d", beginTimescamp as CVarArg, endTimescamp as CVarArg, userId)
        request.fetchLimit = count
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        let listData = (try! context.fetch(request)) as! [EvaluationData]
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func queryNoUploadEvaluationDatas() -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(value: false as Bool))
        
        let listData = (try! context.fetch(request)) as! [EvaluationData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func updateUploadEvaluationDatas(_ newDataIdInfos: [[String: AnyObject]]) {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(value: false as Bool))
        
        let listData = (try! context.fetch(request)) as! [EvaluationData]
        
        if listData.count != newDataIdInfos.count {
            return
        }
        
        if listData.count > 0 {
            for i in 0...listData.count-1 {
                
                let managedObject = listData[i]
                let info = newDataIdInfos[i]
                managedObject.dataId = info["dataId"] as? String
                managedObject.isUpload = NSNumber(value: true as Bool)
            }
        }
        
        do {
            try context.save()
        }catch let error1 as NSError {
            print(error1)
        }
    }
    
    func queryLastEvaluationData(_ userId: Int) -> [String : AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %@", NSNumber(value: userId as Int))
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        request.fetchLimit = 1
        
        if let listData = (try? context.fetch(request)) as? [EvaluationData] {
            if listData.count > 0 {
                return convertModel(listData.first!)
            }
        }
        
        return nil
    }
}

// MARK: - 目标数据
extension DBManager {
    
    func addGoalDatas(_ data: BraceletResultProtocol) {
        
        let context = self.managedObjectContext!
        
        for result in data.results {
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "GoalData", into: context) as! GoalData
            
            insertData.dataId = result.dataId
            insertData.userId = NSNumber(value: result.userId as Int)
            insertData.isUpload = false
            
            insertData.startTime = result.startTime
            insertData.endTime = result.endTime
            insertData.steps = NSNumber(value: result.steps as UInt16)
            insertData.stepsType = NSNumber(value: result.stepsType.rawValue as UInt16)
            
        }
        
        do {
            try context.save()
        } catch _ {
            
        }
        
    }
    
    func addGoalData(_ setDatas: @escaping ( _ setDatas: inout GoalData) -> GoalData) {
        
        let context = self.managedObjectContext!
        
        context.perform { () -> Void in
            var insertData = NSEntityDescription.insertNewObject(forEntityName: "GoalData", into: context) as! GoalData
            
            insertData.dataId = UUID().uuidString
            _ = setDatas(&insertData)
            
            do {
                try context.save()
                //            NSLog("Insert GoalData Data Success")
            } catch _ {
                //            NSLog("Insert GoalData Data Fail")
            }
        }
    }
    
    func deleteGoalData(_ dataId: String) {
        let context = self.managedObjectContext!
        
        context.perform { () -> Void in
            let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "dataId == %@", dataId)
            
            var error: NSError? = nil
            let listData:[AnyObject]?
            do {
                listData = try context.fetch(request)
            } catch let error1 as NSError {
                error = error1
                listData = nil
                print(error)
            }
            for data in listData as! [EvaluationData] {
                context.delete(data)
                var savingError: NSError? = nil
                do {
                    try context.save()
                    print("删除成功")
                } catch let error as NSError {
                    savingError = error
                    print("删除失败: \(savingError)")
                }
            }
        }
    }
    
    func deleteGoalDatas(_ date: Date) {
        let context = self.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "endTime <= %@", date as CVarArg)
        
        var error: NSError? = nil
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        
        if let datas = listData {
            for data in datas as! [GoalData] {
                context.delete(data)
            }
            
            do {
                try context.save()
            } catch _ {
                
            }
        }
        
    }
    
    func queryGoalData(_ dataId: String) -> [String: AnyObject]? {
        
        let context = self.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        
        for data in listData as! [GoalData] {
            return goalDataToDic(data)
        }
        
        return nil
    }
    
    func queryLastGoalData() -> [String: AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.fetchLimit = 1
        let endDateSort = NSSortDescriptor(key: "endTime", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        
        for data in listData as! [GoalData] {
            return goalDataToDic(data)
        }
        
        return nil
    }
    
    func queryGoalData(_ beginDate: Date, endDate: Date) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "startTime >= %@ and endTime < %@", beginDate as CVarArg, endDate as CVarArg)
        
        let listData: [NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [goalDataToDic(managedObject)]
        }
        
        return datas
    }
    
    func queryNoUploadGoalDatas() -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(value: false as Bool))
        
        let listData = (try! context.fetch(request)) as! [GoalData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [goalDataToDic(managedObject)]
        }
        return datas
    }
    
    func updateUploadGoalDatas(_ newDataIdInfos: [[String: AnyObject]]) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "GoalData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(value: false as Bool))
        
        let listData = (try! context.fetch(request)) as! [GoalData]
        
        if listData.count != newDataIdInfos.count {
            return
        }
        
        var i = 0
        while i < listData.count && i < newDataIdInfos.count {
            let managedObject = listData[i]
            let info = newDataIdInfos[i]
            managedObject.dataId =  String(format: "%@", info["dataid"] as! NSNumber)
            managedObject.isUpload = NSNumber(value: true as Bool)
            
            i += 1
        }
        
        do {
            try context.save()
        }catch let error1 as NSError {
            print(error1)
        }
    }
}

// MARK: - Device Model 操作
extension DBManager {
    
    func haveConnectedWithType(_ type: DeviceType) -> Bool {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
        }
        
        if error == nil && listData?.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func removeDeviceBind(_ type: DeviceType) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        
        var error: NSError? = nil
        let listData:[AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        for data in listData as! [Device] {
            context.delete(data)
            var savingError: NSError? = nil
            do {
                try context.save()
                print("删除成功")
            } catch let error as NSError {
                savingError = error
                print("删除失败: \(savingError)")
            }
        }
    }
    
    var haveConnectedScale: Bool {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d OR type == %d OR type == %d", DeviceType.myBody.rawValue, DeviceType.myBodyMini.rawValue, DeviceType.myBodyPlus.rawValue)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
        }
        
        if error == nil && listData?.count > 0 {
            return true
        }
        else {
            return false
        }
        
    }
    
    var haveConnectedBracelet: Bool {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == 1")
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
        }
        
        if error == nil && listData?.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func addDevice(_ uuid: String, name: String, type: DeviceType) {
        
        let context = self.managedObjectContext!
        
        // 先搜索
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
        }
        
        if error == nil && listData?.count > 0 {
            NSLog("Insert Device Fail, exist the UUID")
        }
        else {
            let insertData = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context) as! Device
            
            insertData.uuid = uuid
            insertData.name = name
            insertData.type = NSNumber(value: type.rawValue as Int16)
            
            do {
                try context.save()
                NSLog("Insert Device Data Success")
            } catch _ {
                NSLog("Insert Device Data Fail")
            }
        }
    }
    
    func braceletInfo() -> (uuid: String, name: String)? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == 1")
        request.fetchLimit = 1
        
        if let listData = try? context.fetch(request) as? [Device] {
            if listData!.count > 0 {
                let model = listData!.first
                return (model!.value(forKey: "uuid") as! String, model?.value(forKey: "name") as! String)
            }
        }
        
        return nil
    }
    
    func myBodyInfo() -> (uuid: String, name: String)? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "Device", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d OR type == %d OR type == %d", DeviceType.myBody.rawValue, DeviceType.myBodyMini.rawValue, DeviceType.myBodyPlus.rawValue)
        request.fetchLimit = 1
        
        if let listData = try? context.fetch(request) as? [Device] {
            if listData!.count > 0 {
                let model = listData!.first
                return (model!.value(forKey: "uuid") as! String, model?.value(forKey: "name") as! String)
            }
        }
        
        return nil
    }
}

// MARK: - 分享数据
extension DBManager {
    func addShareData(_ type: Int) {
        
        let context = self.managedObjectContext!
        let insertData = NSEntityDescription.insertNewObject(forEntityName: "ShareData", into: context) as! ShareData
        
        insertData.type = NSNumber(value: type as Int)
        insertData.date = Date()
        
        do {
            try context.save()
            NSLog("Insert Share Data Success")
        } catch _ {
            NSLog("Insert Share Data Fail")
        }
    }
    
    func queryShareDatas(_ beginDate: Date, endDate: Date) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entity(forEntityName: "ShareData", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as CVarArg, endDate as CVarArg)
        
        let listData: [NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [shareDataToDic(managedObject)]
        }
        
        return datas
        
    }
}

/*
dataId: String
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
*/
// MARK: - 数据工厂
extension DBManager {
    
    func shareDataToDic(_ shareData: NSManagedObject) -> [String : AnyObject] {
        return [
            "type" : shareData.value(forKey: "type") as! NSNumber,
            "date" : shareData.value(forKey: "date") as! Date as AnyObject,
        ]
    }
    
    func goalDataToDic(_ goalData: NSManagedObject) -> [String: AnyObject] {
        return [
            "stepsType" : goalData.value(forKey: "stepsType") as! NSNumber,
            "steps" : goalData.value(forKey: "steps") as! NSNumber,
            "dataId" : goalData.value(forKey: "dataId") as! String as AnyObject,
            "userId" : goalData.value(forKey: "userId") as! NSNumber,
            "isUpload" : goalData.value(forKey: "isUpload") as! NSNumber,
            "startTime" : goalData.value(forKey: "startTime") as! Date as AnyObject,
            "endTime" : goalData.value(forKey: "endTime") as! Date as AnyObject,
        ]
    }
    
    func userToDic(_ user: UserDBData) -> [String: AnyObject] {
        
        /*
        @NSManaged var age: NSNumber
        @NSManaged var height: NSNumber
        @NSManaged var name: String
        @NSManaged var userId: NSNumber
        @NSManaged var gender: NSNumber
*/
        var info: [String: NSObject] = [
            "age" : user.value(forKey: "age") as! NSNumber,
            "height" : user.value(forKey: "height") as! NSNumber,
            "name" : user.value(forKey: "name") as! String as NSObject,
            "userId" : user.value(forKey: "userId") as! NSNumber,
            "gender" : user.value(forKey: "gender") as! NSNumber,
        ]
        if let headURL = user.value(forKey: "headURL") as? String {
            info["headURL"] = headURL as NSObject
        }
        else {
            info["headURL"] = "" as NSObject
        }
        
        return info
    }
    
    func convertModel(_ data: EvaluationData) -> [String: AnyObject] {
        let dataId = data.value(forKey: "dataId") as! String
        let isUpload = (data.value(forKey: "isUpload") as! NSNumber)
        let timeStamp = (data.value(forKey: "timeStamp") as! Date)
        let userId = (data.value(forKey: "userId") as! NSNumber)
        let weight = (data.value(forKey: "weight") as! NSNumber)
        let waterPercentage = (data.value(forKey: "waterPercentage") as! NSNumber)
        let visceralFatPercentage = (data.value(forKey: "visceralFatPercentage") as! NSNumber)
        let fatPercentage = (data.value(forKey: "fatPercentage") as! NSNumber)
        let fatWeight = (data.value(forKey: "fatWeight") as! NSNumber)
        let waterWeight = (data.value(forKey: "waterWeight") as! NSNumber)
        let muscleWeight = (data.value(forKey: "muscleWeight") as! NSNumber)
        let proteinWeight = (data.value(forKey: "proteinWeight") as! NSNumber)
        let boneWeight = (data.value(forKey: "boneWeight") as! NSNumber)
        let boneMuscleWeight = (data.value(forKey: "boneMuscleWeight") as! NSNumber)
        
        
        var info: [String : AnyObject] = [:]
        
        info["deviceType"] = (data.value(forKey: "deviceType") as! NSNumber)
        
        info["dataId"] = dataId as AnyObject
        info["userId"] = userId as AnyObject
        info["timeStamp"] = timeStamp as AnyObject
        info["isUpload"] = isUpload
        
        info["boneMuscleWeight"] = boneMuscleWeight
        info["boneWeight"] = boneWeight
        info["fatPercentage"] = fatPercentage
        info["fatWeight"] = fatWeight
        info["muscleWeight"] = muscleWeight
        info["proteinWeight"] = proteinWeight
        info["visceralFatPercentage"] = visceralFatPercentage
        info["waterPercentage"] = waterPercentage
        info["waterWeight"] = waterWeight
        info["weight"] = weight
        
        // 脂肪肝  1为有  2为没有  0为不支持
        if let hepaticAdiposeInfiltration = data.value(forKey: "hepaticAdiposeInfiltration") as? NSNumber {
            if hepaticAdiposeInfiltration.intValue == 1 {
                info["hepaticAdiposeInfiltration"] = NSNumber(value: true as Bool)
            } else if hepaticAdiposeInfiltration.intValue == 2 {
                info["hepaticAdiposeInfiltration"] = NSNumber(value: false as Bool)
            }
        }
        
        
        info["fatFreeBodyWeight"] = data.value(forKey: "fatFreeBodyWeight") as! NSNumber
        info["fatFreeBodyWeightMin"] = data.value(forKey: "fatFreeBodyWeightMin") as! NSNumber
        info["fatFreeBodyWeightMax"] = data.value(forKey: "fatFreeBodyWeightMax") as! NSNumber
        info["muscleWeightMin"] = data.value(forKey: "muscleWeightMin") as! NSNumber
        info["muscleWeightMax"] = data.value(forKey: "muscleWeightMax") as! NSNumber
        info["proteinWeightMin"] = data.value(forKey: "proteinWeightMin") as! NSNumber
        info["proteinWeightMax"] = data.value(forKey: "proteinWeightMax") as! NSNumber
        info["boneWeightMin"] = data.value(forKey: "boneWeightMin") as! NSNumber
        info["boneWeightMax"] = data.value(forKey: "boneWeightMax") as! NSNumber
        info["waterWeightMin"] = data.value(forKey: "waterWeightMin") as! NSNumber
        info["waterWeightMax"] = data.value(forKey: "waterWeightMax") as! NSNumber
        info["fatWeightMin"] = data.value(forKey: "fatWeightMin") as! NSNumber
        info["fatWeightMax"] = data.value(forKey: "fatWeightMax") as! NSNumber
        info["fatPercentageMin"] = data.value(forKey: "fatPercentageMin") as! NSNumber
        info["fatPercentageMax"] = data.value(forKey: "fatPercentageMax") as! NSNumber
        info["whr"] = data.value(forKey: "whr") as! NSNumber
        info["whrMin"] = data.value(forKey: "whrMin") as! NSNumber
        info["whrMax"] = data.value(forKey: "whrMax") as! NSNumber
        info["bmi"] = data.value(forKey: "bmi") as! NSNumber
        info["bmiMin"] = data.value(forKey: "bmiMin") as! NSNumber
        info["bmiMax"] = data.value(forKey: "bmiMax") as! NSNumber
        info["bmr"] = data.value(forKey: "bmr") as! NSNumber
        info["bodyAge"] = data.value(forKey: "bodyAge") as! NSNumber
        let boneMuscleWeightMin = data.value(forKey: "boneMuscleWeightMin") as! NSNumber
        let boneMuscleWeightMax = data.value(forKey: "boneMuscleWeightMax") as! NSNumber
        info["boneMuscleWeightMin"] = boneMuscleWeightMin
        info["boneMuscleWeightMax"] = boneMuscleWeightMax
        info["muscleControl"] = data.value(forKey: "muscleControl") as! NSNumber
        info["fatControl"] = data.value(forKey: "fatControl") as! NSNumber
        info["weightControl"] = data.value(forKey: "weightControl") as! NSNumber
        info["sw"] = data.value(forKey: "sw") as! NSNumber
        info["swMin"] = data.value(forKey: "swMin") as! NSNumber
        info["swMax"] = data.value(forKey: "swMax") as! NSNumber
        info["goalWeight"] = data.value(forKey: "goalWeight") as! NSNumber
        info["m_smm"] = data.value(forKey: "m_smm") as! NSNumber
        info["rightUpperExtremityFat"] = data.value(forKey: "rightUpperExtremityFat") as! NSNumber
        info["rightUpperExtremityMuscle"] = data.value(forKey: "rightUpperExtremityMuscle") as! NSNumber
        info["rightUpperExtremityBone"] = data.value(forKey: "rightUpperExtremityBone") as! NSNumber
        info["leftUpperExtremityFat"] = data.value(forKey: "leftUpperExtremityFat") as! NSNumber
        info["leftUpperExtremityMuscle"] = data.value(forKey: "leftUpperExtremityMuscle") as! NSNumber
        info["leftUpperExtremityBone"] = data.value(forKey: "leftUpperExtremityBone") as! NSNumber
        info["trunkLimbFat"] = data.value(forKey: "trunkLimbFat") as! NSNumber
        info["trunkLimbMuscle"] = data.value(forKey: "trunkLimbMuscle") as! NSNumber
        info["trunkLimbBone"] = data.value(forKey: "trunkLimbBone") as! NSNumber
        info["rightLowerExtremityFat"] = data.value(forKey: "rightLowerExtremityFat") as! NSNumber
        info["rightLowerExtremityMuscle"] = data.value(forKey: "rightLowerExtremityMuscle") as! NSNumber
        info["rightLowerExtremityBone"] = data.value(forKey: "rightLowerExtremityBone") as! NSNumber
        info["leftLowerExtremityFat"] = data.value(forKey: "leftLowerExtremityFat") as! NSNumber
        info["leftLowerExtremityMuscle"] = data.value(forKey: "leftLowerExtremityMuscle") as! NSNumber
        info["leftLowerExtremityBone"] = data.value(forKey: "leftLowerExtremityBone") as! NSNumber
        
        info["externalMoisture"] = data.value(forKey: "externalMoisture") as! NSNumber
        info["internalMoisture"] = data.value(forKey: "internalMoisture") as! NSNumber
        info["edemaFactor"] = data.value(forKey: "edemaFactor") as! NSNumber
        info["obesity"] = data.value(forKey: "obesity") as! NSNumber
        let score = data.value(forKey: "score") as! NSNumber
        info["score"] = score
        
        print("timeStamptimeStamp \(info["timeStamp"])")
        
        return info
    }
}
