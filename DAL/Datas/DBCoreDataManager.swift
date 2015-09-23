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
    
    func deleteUser(userId: UInt8) {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
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
    
    func queryAllUser() -> [[String : NSObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("UserDBData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var datas: [[String: NSObject]] = []
        if let listData = (try? context.executeFetchRequest(request)) as? [UserDBData] {
            for managedObject in listData {
                datas += [userToDic(managedObject)]
            }
        }
        
        return datas
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
    
    func deleteEvaluationData(dataId: String) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
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
    
    func queryEvaluationData(dataId: String) -> [String: NSObject]? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
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
    
    func queryEvaluationDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: NSObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp <= %@", beginTimescamp, endTimescamp)
        let endDateSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [endDateSort]
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        var datas: [[String: NSObject]] = []
        for managedObject in listData {
            datas += [convertModel(managedObject)]
        }
        return datas
    }
    
    func queryNoUploadEvaluationDatas() -> [[String: NSObject]] {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "isUpload == %@", NSNumber(bool: false))
        
        let listData = (try! context.executeFetchRequest(request)) as! [EvaluationData]
        
        var datas: [[String: NSObject]] = []
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
        
        for i in 0...listData.count - 1 {
            
            let managedObject = listData[i]
            let info = newDataIdInfos[i]
            managedObject.dataId = info["dataId"] as! String
            managedObject.isUpload = NSNumber(bool: true)
        }
        
        do {
            try context.save()
        }catch let error1 as NSError {
            print(error1)
        }
        
    }
}

// MARK: - 目标数据
extension DBManager {
    func addGoalData(setDatas: (inout setDatas: GoalData) -> GoalData) {
        
        let context = self.managedObjectContext!
        
        // 先搜索
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        var insertData = NSEntityDescription.insertNewObjectForEntityForName("GoalData", inManagedObjectContext: context) as! GoalData
        setDatas(setDatas: &insertData)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "startTime == %@ AND endTime == %@", insertData.startTime, insertData.endTime)
        
        let listData: [AnyObject]?
        listData = try? context.executeFetchRequest(request)
        
        if listData?.count > 0 {
            NSLog("Insert Device Fail, exist the GoalData")
        }
        else {
            do {
                try context.save()
                NSLog("Insert GoalData Data Success")
            } catch _ {
                NSLog("Insert GoalData Data Fail")
            }
        }
    }
    
    func deleteGoalData(dataId: String) {
        let context = self.managedObjectContext!
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
    
    func queryGoalData(dataId: String) -> [String: NSObject]? {
        
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
    
    func queryLastGoalData() -> [String: NSObject]? {
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
    
    func queryGoalData(beginDate: NSDate, endDate: NSDate) -> [[String: NSObject]] {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "startTime >= %@ and endTime < %@", beginDate, endDate)
        
//        request.fetchLimit = 1
//        var endDateSort = NSSortDescriptor(key: "endTime", ascending: true)
//        request.sortDescriptors = [endDateSort]
        
//        var error: NSError? = nil
        let listData: [GoalData] = (try! context.executeFetchRequest(request)) as! [GoalData]
        
//        var results: [[String: NSObject]] = []
        
        var datas: [[String: NSObject]] = []
        for managedObject in listData {
            datas += [goalDataToDic(managedObject)]
        }
        
        return datas
    }
}

// MARK: - Device Model 操作
extension DBManager {
    var haveConnectedScale: Bool {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("Device", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "type == 0")
        
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
    
    func addDevice(uuid: String, name: String, type: Int16) {
        
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
            insertData.type = NSNumber(short: type)
            
            do {
                try context.save()
                NSLog("Insert Device Data Success")
            } catch _ {
                NSLog("Insert Device Data Fail")
            }
        }
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
    
    func goalDataToDic(goalData: GoalData) -> [String: NSObject] {
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
    
    func userToDic(user: UserDBData) -> [String: NSObject] {
        
        /*
        @NSManaged var age: NSNumber
        @NSManaged var height: NSNumber
        @NSManaged var name: String
        @NSManaged var userId: NSNumber
        @NSManaged var gender: NSNumber
*/
        return [
            "age" : user.valueForKey("age") as! NSNumber,
            "height" : user.valueForKey("height") as! NSNumber,
            "name" : user.valueForKey("name") as! String,
            "userId" : user.valueForKey("") as! NSNumber,
            "gender" : user.valueForKey("gender") as! NSNumber,
        ]
    }
    
    func convertModel(data: EvaluationData) -> [String: NSObject] {
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
        
        return [
            "dataId" : dataId,
            "isUpload" : isUpload,
            "timeStamp" : timeStamp,
            "userId" : userId,
            "weight" : weight,
            "waterPercentage" : waterPercentage,
            "visceralFatPercentage" : visceralFatPercentage,
            "fatPercentage" : fatPercentage,
            "fatWeight" : fatWeight,
            "waterWeight" : waterWeight,
            "muscleWeight" : muscleWeight,
            "proteinWeight" : proteinWeight,
            "boneWeight" : boneWeight,
            "boneMuscleWeight" : boneMuscleWeight,
            ]
    }
}
