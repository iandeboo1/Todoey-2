//
//  Item.swift
//  Todoey
//
//  Created by Ian DeBoo on 4/10/19.
//  Copyright © 2019 Ian DeBoo. All rights reserved.
//

import UIKit

class Item: Codable {
    //needs to conform to encodable rules to be able to be placed in a JSON or PLIST; can't contain any custom objects, only standard data types
    var label : String = ""
    var done : Bool = false
    
}
