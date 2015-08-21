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
        return urls[urls.count-1] as! NSURL
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
        println("db Path: \(url)")
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }
    
    
}

extension DBManager: DBManagerProtocol {
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func addEvaluationData(setDatas:(inout setDatas: EvaluationData)-> EvaluationData) {
        
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObjectForEntityForName("EvaluationData", inManagedObjectContext: context) as! EvaluationData
        
        setDatas(setDatas: &insertData)
        
        if context.save(nil) {
            NSLog("Insert Evaluation Data Success")
        }
        else
        {
            NSLog("Insert Evaluation Data Fail")
        }
    }
    
    func deleteEvaluationData(dataId: String) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData:[AnyObject]? = context.executeFetchRequest(request, error: &error)
        for data in listData as! [EvaluationData] {
            context.deleteObject(data)
            var savingError: NSError? = nil
            if context.save(&savingError) {
                println("删除成功")
            }else{
                println("删除失败")
            }
        }
    }
    
    func queryEvaluationData(dataId: String) -> EvaluationData? {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("EvaluationData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData: [AnyObject]? = context.executeFetchRequest(request, error: &error)
        
        for data in listData as! [EvaluationData] {
            return data
        }
        
        return nil
    }
    
    func addGoalData(setDatas: (inout setDatas: GoalData) -> GoalData) {
        
        let context = self.managedObjectContext!
        var insertData = NSEntityDescription.insertNewObjectForEntityForName("GoalData", inManagedObjectContext: context) as! GoalData
        
        setDatas(setDatas: &insertData)
        
        if context.save(nil) {
            NSLog("Insert GoalData Data Success")
        } else {
            NSLog("Insert GoalData Data Fail")
        }
    }
    
    func deleteGoalData(dataId: String) {
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData:[AnyObject]? = context.executeFetchRequest(request, error: &error)
        for data in listData as! [EvaluationData] {
            context.deleteObject(data)
            var savingError: NSError? = nil
            if context.save(&savingError) {
                println("删除成功")
            }else{
                println("删除失败")
            }
        }
    }
    
    func queryGoalData(dataId: String) -> GoalData? {
        
        let context = self.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName("GoalData", inManagedObjectContext: context)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "dataId == %@", dataId)
        
        var error: NSError? = nil
        let listData: [AnyObject]? = context.executeFetchRequest(request, error: &error)
        
        for data in listData as! [GoalData] {
            return data
        }
        
        return nil
    }
}
