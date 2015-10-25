//
//  DBCoreDataManager.swift
//  Health
//
//  Created by Yalin on 15/8/15.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreData

extension DBManager {
    
    // MARK: - Core Data stack
    
    var applicationDocumentsDirectory: NSURL  {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yalin.Test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }
    
    var managedObjectModel: NSManagedObjectModel {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Health", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.userId!).sqlite")
//        print("db Path: \(url)")
        
        var error: NSError? = nil
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch let error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
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
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }
    
    
}

// MARK: - User Model操作
extension DBManager: DBUserProtocol {
    
    func addUser(setDatas: (setDatas: inout UserDBData) -> UserDBData) {
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObjectForEntityForName("UserDBData", inManagedObjectContext: context) as! UserDBData
        
        setDatas(setDatas: &insertData)
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
    }
    
    func addOrUpdateUser(userModel: UserModel) {
        
        if let _ = queryUser(userModel.userId) {
            // 更新
            let context = self.managedObjectContext!
            let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
            
            let request = NSFetchRequest()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "userId == %d", userModel.userId)
            
            let listData = (try! context.executeFetchRequest(request)) as! [UserDBData]
            
            for var i = 0; i < listData.count; i++ {
                
                let managedObject = listData[i]
                managedObject.name = userModel.name
                if let headURL = userModel.headURL {
                    managedObject.headURL = headURL
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
            let insertData = NSEntityDescription.insertNewObjectForEntityForName("UserDBData", inManagedObjectContext: context) as! UserDBData
            
            insertData.userId = NSNumber(integer: userModel.userId)
            insertData.age = NSNumber(unsignedChar: userModel.age)
            insertData.height = NSNumber(unsignedChar: userModel.height)
            insertData.gender = NSNumber(bool: userModel.gender)
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
    
    func deleteUser(userId: Int) {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %d", userId)
        
        let listData:[AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            print(error1)
            listData = nil
        }
        for data in listData as! [UserDBData] {
            context.deleteObject(data)
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
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var datas: [[String: AnyObject]] = []
        if let listData = (try? context.executeFetchRequest(request)) as? [UserDBData] {
            for managedObject in listData {
                datas += [userToDic(managedObject)]
            }
        }
        
        return datas
    }
    
    func queryUser(userId: Int) -> [String: AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %d", userId)
        request.fetchLimit = 1
        
        if let listData = (try? context.executeFetchRequest(request)) as? [UserDBData] {
            for managedObject in listData {
                return userToDic(managedObject)
            }
        }
        
        return nil
    }
    
    func deleteAllUser() {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        let listData:[AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            print(error1)
            listData = nil
        }
        for data in listData as! [UserDBData] {
            context.deleteObject(data)
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
    
    func addEvaluationData(result: ScaleResultProtocol) {
        let context = self.managedObjectContext!
        let insertData = NSEntityDescription.insertNewObjectForEntityForName("EvaluationData", inManagedObjectContext: context) as! EvaluationData
        
        if let _ = result as? MyBodyResult {
            insertData.deviceType = 0
        }
        if let _ = result as? MyBodyMiniAndPlusResult {
            insertData.deviceType = 1
        }
        
        insertData.dataId = result.dataId
        insertData.userId = result.userId
        insertData.timeStamp = NSDate()
        insertData.isUpload = false
        
        insertData.boneMuscleWeight = result.boneMuscleWeight
        insertData.boneWeight = result.boneWeight
        insertData.fatPercentage = result.fatPercentage
        insertData.fatWeight = result.fatWeight
        insertData.muscleWeight = result.muscleWeight
        insertData.proteinWeight = result.proteinWeight
        insertData.visceralFatPercentage = result.visceralFatPercentage
        insertData.waterPercentage = result.waterPercentage
        insertData.waterWeight = result.waterWeight
        insertData.weight = result.weight
        // 脂肪肝
        if let hepaticAdiposeInfiltration = result.hepaticAdiposeInfiltration {
            insertData.hepaticAdiposeInfiltration = hepaticAdiposeInfiltration ? 1 : 2  // 1为有  2为没有
        }
        else {
            insertData.hepaticAdiposeInfiltration = 0 // 0为不支持
        }
        insertData.fatFreeBodyWeight = result.fatFreeBodyWeight
        insertData.fatFreeBodyWeightMin = result.fatFreeBodyWeightRange.0
        insertData.fatFreeBodyWeightMax = result.fatFreeBodyWeightRange.1
        insertData.muscleWeightMin = result.muscleWeightRange.0
        insertData.muscleWeightMax = result.muscleWeightRange.1
        insertData.proteinWeightMin = result.proteinWeightRange.0
        insertData.proteinWeightMax = result.proteinWeightRange.1
        insertData.boneWeightMin = result.boneWeightRange.0
        insertData.boneWeightMax = result.boneWeightRange.1
        insertData.waterWeightMin = result.waterWeightRange.0
        insertData.waterWeightMax = result.waterWeightRange.1
        insertData.fatWeightMin = result.fatWeightRange.0
        insertData.fatWeightMax = result.fatWeightRange.1
        insertData.fatPercentageMin = result.fatPercentageRange.0
        insertData.fatPercentageMax = result.fatPercentageRange.1
        insertData.whr = result.WHR
        insertData.whrMin = result.WHRRange.0
        insertData.whrMax = result.WHRRange.1
        insertData.bmi = result.BMI
        insertData.bmiMin = result.BMIRange.0
        insertData.bmiMax = result.BMIRange.1
        insertData.bmr = result.BMR
        insertData.bodyAge = result.bodyAge
        insertData.boneMuscleWeightMin = result.boneMuscleRange.0
        insertData.boneMuscleWeightMax = result.boneMuscleRange.1
        insertData.muscleControl = result.muscleControl
        insertData.fatControl = result.fatControl
        insertData.weightControl = result.weightControl
        insertData.sw = result.SW
        insertData.swMin = result.SWRange.0
        insertData.swMax = result.SWRange.1
        insertData.goalWeight = result.goalWeight
        insertData.m_smm = result.m_smm
        insertData.rightUpperExtremityFat = result.rightUpperExtremityFat
        insertData.rightUpperExtremityMuscle = result.rightUpperExtremityMuscle
        insertData.rightUpperExtremityBone = result.rightUpperExtremityBone
        insertData.leftUpperExtremityFat = result.leftUpperExtremityFat
        insertData.leftUpperExtremityMuscle = result.leftUpperExtremityMuscle
        insertData.leftUpperExtremityBone = result.leftUpperExtremityBone
        insertData.trunkLimbFat = result.trunkLimbFat
        insertData.trunkLimbMuscle = result.trunkLimbMuscle
        insertData.trunkLimbBone = result.trunkLimbBone
        insertData.rightLowerExtremityFat = result.rightLowerExtremityFat
        insertData.rightLowerExtremityMuscle = result.rightLowerExtremityMuscle
        insertData.rightLowerExtremityBone = result.rightLowerExtremityBone
        insertData.leftLowerExtremityFat = result.leftLowerExtremityFat
        insertData.leftLowerExtremityMuscle = result.leftLowerExtremityMuscle
        insertData.leftLowerExtremityBone = result.leftLowerExtremityBone
        insertData.externalMoisture = result.externalMoisture
        insertData.internalMoisture = result.internalMoisture
        insertData.edemaFactor = result.edemaFactor
        insertData.obesity = result.obesity
        insertData.score = result.score
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
        
    }
    
    func addEvaluationData(setDatas:(inout setDatas: EvaluationData)-> EvaluationData) {
        
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObjectForEntityForName("EvaluationData", inManagedObjectContext: context) as! EvaluationData
        
        insertData.dataId = NSUUID().UUIDString
        setDatas(setDatas: &insertData)
        
        do {
            try context.save()
            NSLog("Insert Evaluation Data Success")
        } catch _ {
            NSLog("Insert Evaluation Data Fail")
        }
    }
    
    func deleteEvaluationData(dataId: String, userId: Int) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@ AND userId == %@", dataId, userId)
        
        let listData:[AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error as NSError {
            print(error)
            listData = nil
        }
        for data in listData as! [EvaluationData] {
            context.deleteObject(data)
            do {
                try context.save()
                print("删除成功")
            } catch let error as NSError {
                print("删除失败: \(error)")
            }
        }
    }
    
    func queryEvaluationData(dataId: String, userId: Int) -> [String: AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@ AND userId == %@", dataId, userId)
        
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error as NSError {
            print(error)
            listData = nil
        }
        
        for data in listData as! [EvaluationData] {
            return convertModel(data)
        }
        
        return nil
    }
    
    func queryEvaluationDatas(beginTimescamp: NSDate, endTimescamp: NSDate, userId: Int) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp <= %@ AND userId == %d", beginTimescamp, endTimescamp, userId)
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func queryCountEvaluationDatas(beginTimescamp: NSDate, endTimescamp: NSDate, userId: Int, count: Int) -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp <= %@ AND userId == %d", beginTimescamp, endTimescamp, userId)
        request.fetchLimit = count
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func queryNoUploadEvaluationDatas() -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(bool: false))
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func updateUploadEvaluationDatas(newDataIdInfos: [[String: AnyObject]]) {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(bool: false))
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        for var i = 0; i < listData.count; i++ {
            
            let managedObject = listData[i]
            let info = newDataIdInfos[i]
            managedObject.dataId = info["dataId"] as? String
            managedObject.isUpload = NSNumber(bool: true)
        }
        
        do {
            try context.save()
        }catch let error1 as NSError {
            print(error1)
        }
        
    }
    
    func queryLastEvaluationData(userId: Int) -> [String : AnyObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %@", NSNumber(integer:userId))
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        request.fetchLimit = 1
        
        if let listData = (try? context.executeFetchRequest(request)) as? [EvaluationData] {
            if listData.count > 0 {
                return convertModel(listData.first!)
            }
        }
        
        return nil
    }
}

// MARK: - 目标数据
extension DBManager {
    
    func addGoalDatas(data: BraceletResultProtocol) {
        
        let context = self.managedObjectContext!
        
        for result in data.results {
            let insertData = NSEntityDescription.insertNewObjectForEntityForName("GoalData", inManagedObjectContext: context) as! GoalData
            
            insertData.dataId = result.dataId
            insertData.userId = NSNumber(integer: result.userId)
            insertData.isUpload = false
            
            insertData.startTime = result.startTime
            insertData.endTime = result.endTime
            insertData.steps = NSNumber(unsignedShort: result.steps)
            insertData.stepsType = NSNumber(unsignedShort: result.stepsType.rawValue)
            
        }
        
        do {
            try context.save()
        } catch _ {
            
        }
        
    }
    
    func addGoalData(setDatas: (inout setDatas: GoalData) -> GoalData) {
        
        let context = self.managedObjectContext!
        
        context.performBlock { () -> Void in
            var insertData = NSEntityDescription.insertNewObjectForEntityForName("GoalData", inManagedObjectContext: context) as! GoalData
            
            insertData.dataId = NSUUID().UUIDString
            setDatas(setDatas: &insertData)
            
            do {
                try context.save()
                //            NSLog("Insert GoalData Data Success")
            } catch _ {
                //            NSLog("Insert GoalData Data Fail")
            }
        }
    }
    
    func deleteGoalData(dataId: String) {
        let context = self.managedObjectContext!
        
        context.performBlock { () -> Void in
            let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
            
            let request = NSFetchRequest()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "dataId == %@", dataId)
            
            var error: NSError? = nil
            let listData:[AnyObject]?
            do {
                listData = try context.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                listData = nil
                print(error)
            }
            for data in listData as! [EvaluationData] {
                context.deleteObject(data)
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
    
    func deleteGoalDatas(date: NSDate) {
        let context = self.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "endTime <= %@", date)
        
        var error: NSError? = nil
        let listData:[AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        
        if let datas = listData {
            for data in datas as! [EvaluationData] {
                context.deleteObject(data)
            }
            
            do {
                try context.save()
            } catch _ {
                
            }
        }
        
    }
    
    func queryGoalData(dataId: String) -> [String: AnyObject]? {
        
        let context = self.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
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
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.fetchLimit = 1
        let endDateSort = NSSortDescriptor(key: "endTime", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
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
    
    func queryGoalData(beginDate: NSDate, endDate: NSDate) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "startTime >= %@ and endTime < %@", beginDate, endDate)
        
        let listData: [NSManagedObject] = (try! context.executeFetchRequest(request)) as! [NSManagedObject]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [goalDataToDic(managedObject)]
        }
        
        return datas
    }
    
    func queryNoUploadGoalDatas() -> [[String: AnyObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(bool: false))
        
        let listData = (try! context.executeFetchRequest(request)) as! [GoalData]
        
        var datas: [[String: AnyObject]] = []
        for managedObject in listData {
            datas += [goalDataToDic(managedObject)]
        }
        return datas
    }
    
    func updateUploadGoalDatas(newDataIdInfos: [[String: AnyObject]]) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(bool: false))
        
        let listData = (try! context.executeFetchRequest(request)) as! [GoalData]
        
        for var i = 0; i < listData.count && i < newDataIdInfos.count; i++ {
            
            let managedObject = listData[i]
            let info = newDataIdInfos[i]
            managedObject.dataId =  String(format: "%@", info["dataid"] as! NSNumber)
            managedObject.isUpload = NSNumber(bool: true)
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
    
    func haveConnectedWithType(type: DeviceType) -> Bool {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
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
    
    func removeDeviceBind(type: DeviceType) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        
        var error: NSError? = nil
        let listData:[AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
            print(error)
        }
        for data in listData as! [Device] {
            context.deleteObject(data)
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
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d OR type == %d OR type == %d", DeviceType.MyBody.rawValue, DeviceType.MyBodyMini.rawValue, DeviceType.MyBodyPlus.rawValue)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
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
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == 1")
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
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
    
    func addDevice(uuid: String, name: String, type: DeviceType) {
        
        let context = self.managedObjectContext!
        
        // 先搜索
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        
        var error: NSError? = nil
        let listData: [AnyObject]?
        do {
            listData = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            listData = nil
        }
        
        if error == nil && listData?.count > 0 {
            NSLog("Insert Device Fail, exist the UUID")
        }
        else {
            let insertData = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: context) as! Device
            
            insertData.uuid = uuid
            insertData.name = name
            insertData.type = NSNumber(short: type.rawValue)
            
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
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == 1")
        request.fetchLimit = 1
        
        if let listData = try? context.executeFetchRequest(request) as? [Device] {
            if listData!.count > 0 {
                let model = listData!.first
                return (model!.valueForKey("uuid") as! String, model?.valueForKey("name") as! String)
            }
        }
        
        return nil
    }
    
    func myBodyInfo() -> (uuid: String, name: String)? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == %d OR type == %d OR type == %d", DeviceType.MyBody.rawValue, DeviceType.MyBodyMini.rawValue, DeviceType.MyBodyPlus.rawValue)
        request.fetchLimit = 1
        
        if let listData = try? context.executeFetchRequest(request) as? [Device] {
            if listData!.count > 0 {
                let model = listData!.first
                return (model!.valueForKey("uuid") as! String, model?.valueForKey("name") as! String)
            }
        }
        
        return nil
    }
}

// MARK: - 分享数据
extension DBManager {
    func addShareData(type: Int) {
        
        let context = self.managedObjectContext!
        let insertData = NSEntityDescription.insertNewObjectForEntityForName("ShareData", inManagedObjectContext: context) as! ShareData
        
        insertData.type = NSNumber(integer: type)
        insertData.date = NSDate()
        
        do {
            try context.save()
            NSLog("Insert Share Data Success")
        } catch _ {
            NSLog("Insert Share Data Fail")
        }
    }
    
    func queryShareDatas(beginDate: NSDate, endDate: NSDate) -> [[String: AnyObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("ShareData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "date >= %@ and date < %@", beginDate, endDate)
        
        let listData: [NSManagedObject] = (try! context.executeFetchRequest(request)) as! [NSManagedObject]
        
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
    
    func shareDataToDic(shareData: NSManagedObject) -> [String : AnyObject] {
        return [
            "type" : shareData.valueForKey("type") as! NSNumber,
            "date" : shareData.valueForKey("date") as! NSDate,
        ]
    }
    
    func goalDataToDic(goalData: NSManagedObject) -> [String: AnyObject] {
        return [
            "stepsType" : goalData.valueForKey("stepsType") as! NSNumber,
            "steps" : goalData.valueForKey("steps") as! NSNumber,
            "dataId" : goalData.valueForKey("dataId") as! String,
            "userId" : goalData.valueForKey("userId") as! NSNumber,
            "isUpload" : goalData.valueForKey("isUpload") as! NSNumber,
            "startTime" : goalData.valueForKey("startTime") as! NSDate,
            "endTime" : goalData.valueForKey("endTime") as! NSDate,
        ]
    }
    
    func userToDic(user: UserDBData) -> [String: AnyObject] {
        
        /*
        @NSManaged var age: NSNumber
        @NSManaged var height: NSNumber
        @NSManaged var name: String
        @NSManaged var userId: NSNumber
        @NSManaged var gender: NSNumber
*/
        var info: [String: NSObject] = [
            "age" : user.valueForKey("age") as! NSNumber,
            "height" : user.valueForKey("height") as! NSNumber,
            "name" : user.valueForKey("name") as! String,
            "userId" : user.valueForKey("userId") as! NSNumber,
            "gender" : user.valueForKey("gender") as! NSNumber,
        ]
        if let headURL = user.valueForKey("headURL") as? String {
            info["headURL"] = headURL
        }
        else {
            info["headURL"] = ""
        }
        
        return info
    }
    
    func convertModel(data: EvaluationData) -> [String: AnyObject] {
        let dataId = data.valueForKey("dataId") as! String
        let isUpload = (data.valueForKey("isUpload") as! NSNumber)
        let timeStamp = (data.valueForKey("timeStamp") as! NSDate)
        let userId = (data.valueForKey("userId") as! NSNumber)
        let weight = (data.valueForKey("weight") as! NSNumber)
        let waterPercentage = (data.valueForKey("waterPercentage") as! NSNumber)
        let visceralFatPercentage = (data.valueForKey("visceralFatPercentage") as! NSNumber)
        let fatPercentage = (data.valueForKey("fatPercentage") as! NSNumber)
        let fatWeight = (data.valueForKey("fatWeight") as! NSNumber)
        let waterWeight = (data.valueForKey("waterWeight") as! NSNumber)
        let muscleWeight = (data.valueForKey("muscleWeight") as! NSNumber)
        let proteinWeight = (data.valueForKey("proteinWeight") as! NSNumber)
        let boneWeight = (data.valueForKey("boneWeight") as! NSNumber)
        let boneMuscleWeight = (data.valueForKey("boneMuscleWeight") as! NSNumber)
        
        
        var info: [String : AnyObject] = [:]
        
        info["deviceType"] = (data.valueForKey("deviceType") as! NSNumber)
        
        info["dataId"] = dataId
        info["userId"] = userId
        info["timeStamp"] = timeStamp
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
        if let hepaticAdiposeInfiltration = data.valueForKey("hepaticAdiposeInfiltration") as? NSNumber {
            if hepaticAdiposeInfiltration.integerValue == 1 {
                info["hepaticAdiposeInfiltration"] = NSNumber(bool: true)
            } else if hepaticAdiposeInfiltration.integerValue == 2 {
                info["hepaticAdiposeInfiltration"] = NSNumber(bool: false)
            }
        }
        
        
        info["fatFreeBodyWeight"] = data.valueForKey("fatFreeBodyWeight") as! NSNumber
        info["fatFreeBodyWeightMin"] = data.valueForKey("fatFreeBodyWeightMin") as! NSNumber
        info["fatFreeBodyWeightMax"] = data.valueForKey("fatFreeBodyWeightMax") as! NSNumber
        info["muscleWeightMin"] = data.valueForKey("muscleWeightMin") as! NSNumber
        info["muscleWeightMax"] = data.valueForKey("muscleWeightMax") as! NSNumber
        info["proteinWeightMin"] = data.valueForKey("proteinWeightMin") as! NSNumber
        info["proteinWeightMax"] = data.valueForKey("proteinWeightMax") as! NSNumber
        info["boneWeightMin"] = data.valueForKey("boneWeightMin") as! NSNumber
        info["boneWeightMax"] = data.valueForKey("boneWeightMax") as! NSNumber
        info["waterWeightMin"] = data.valueForKey("waterWeightMin") as! NSNumber
        info["waterWeightMax"] = data.valueForKey("waterWeightMax") as! NSNumber
        info["fatWeightMin"] = data.valueForKey("fatWeightMin") as! NSNumber
        info["fatWeightMax"] = data.valueForKey("fatWeightMax") as! NSNumber
        info["fatPercentageMin"] = data.valueForKey("fatPercentageMin") as! NSNumber
        info["fatPercentageMax"] = data.valueForKey("fatPercentageMax") as! NSNumber
        info["whr"] = data.valueForKey("whr") as! NSNumber
        info["whrMin"] = data.valueForKey("whrMin") as! NSNumber
        info["whrMax"] = data.valueForKey("whrMax") as! NSNumber
        info["bmi"] = data.valueForKey("bmi") as! NSNumber
        info["bmiMin"] = data.valueForKey("bmiMin") as! NSNumber
        info["bmiMax"] = data.valueForKey("bmiMax") as! NSNumber
        info["bmr"] = data.valueForKey("bmr") as! NSNumber
        info["bodyAge"] = data.valueForKey("bodyAge") as! NSNumber
        info["boneMuscleWeightMin"] = data.valueForKey("boneMuscleWeightMin") as! NSNumber
        info["boneMuscleWeightMax"] = data.valueForKey("boneMuscleWeightMax") as! NSNumber
        info["muscleControl"] = data.valueForKey("muscleControl") as! NSNumber
        info["fatControl"] = data.valueForKey("fatControl") as! NSNumber
        info["weightControl"] = data.valueForKey("weightControl") as! NSNumber
        info["sw"] = data.valueForKey("sw") as! NSNumber
        info["swMin"] = data.valueForKey("swMin") as! NSNumber
        info["swMax"] = data.valueForKey("swMax") as! NSNumber
        info["goalWeight"] = data.valueForKey("goalWeight") as! NSNumber
        info["m_smm"] = data.valueForKey("m_smm") as! NSNumber
        info["rightUpperExtremityFat"] = data.valueForKey("rightUpperExtremityFat") as! NSNumber
        info["rightUpperExtremityMuscle"] = data.valueForKey("rightUpperExtremityMuscle") as! NSNumber
        info["rightUpperExtremityBone"] = data.valueForKey("rightUpperExtremityBone") as! NSNumber
        info["leftUpperExtremityFat"] = data.valueForKey("leftUpperExtremityFat") as! NSNumber
        info["leftUpperExtremityMuscle"] = data.valueForKey("leftUpperExtremityMuscle") as! NSNumber
        info["leftUpperExtremityBone"] = data.valueForKey("leftUpperExtremityBone") as! NSNumber
        info["trunkLimbFat"] = data.valueForKey("trunkLimbFat") as! NSNumber
        info["trunkLimbMuscle"] = data.valueForKey("trunkLimbMuscle") as! NSNumber
        info["trunkLimbBone"] = data.valueForKey("trunkLimbBone") as! NSNumber
        info["rightLowerExtremityFat"] = data.valueForKey("rightLowerExtremityFat") as! NSNumber
        info["rightLowerExtremityMuscle"] = data.valueForKey("rightLowerExtremityMuscle") as! NSNumber
        info["rightLowerExtremityBone"] = data.valueForKey("rightLowerExtremityBone") as! NSNumber
        info["leftLowerExtremityFat"] = data.valueForKey("leftLowerExtremityFat") as! NSNumber
        info["leftLowerExtremityMuscle"] = data.valueForKey("leftLowerExtremityMuscle") as! NSNumber
        info["leftLowerExtremityBone"] = data.valueForKey("leftLowerExtremityBone") as! NSNumber
        
        info["externalMoisture"] = data.valueForKey("externalMoisture") as! NSNumber
        info["internalMoisture"] = data.valueForKey("internalMoisture") as! NSNumber
        info["edemaFactor"] = data.valueForKey("edemaFactor") as! NSNumber
        info["obesity"] = data.valueForKey("obesity") as! NSNumber
        info["score"] = data.valueForKey("score") as! NSNumber
        
        return info
    }
}
