//
//  EvaluationData.swift
//  Health
//
//  Created by Yalin on 15/10/14.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(EvaluationData)
class EvaluationData: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "EvaluationData", in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }
}
