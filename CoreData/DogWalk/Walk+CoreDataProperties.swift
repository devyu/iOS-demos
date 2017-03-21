//
//  CoreDataStack.swift
//  Todo
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 JY. All rights reserved.
//


import Foundation
import CoreData

extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?

}
