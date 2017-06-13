//
//  ShareData.swift
//  Health
//
//  Created by Yalin on 15/10/7.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation
import CoreData

@objc(ShareData)
class ShareData: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "ShareData", in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }
}
