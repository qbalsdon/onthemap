//
//  StudentInformation.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/24.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

struct StudentInformation {
    var createdAt : String!
    var firstName : String!
    var lastName : String!
    var latitude : NSNumber!
    var longitude : NSNumber!
    var mapString : String!
    var mediaURL : String!
    var objectId : String!
    var uniqueKey : String!
    var updatedAt : String!
    
    init(){
    }
    
    init(data: NSDictionary!){
        createdAt = data.valueForKey("createdAt") as! String
        firstName = data.valueForKey("firstName") as! String
        lastName = data.valueForKey("lastName") as! String
        latitude = data.valueForKey("latitude") as! NSNumber
        longitude = data.valueForKey("longitude") as! NSNumber
        mapString = data.valueForKey("mapString") as! String
        mediaURL = data.valueForKey("mediaURL") as! String
        objectId = data.valueForKey("objectId") as! String
        uniqueKey = data.valueForKey("uniqueKey") as! String
        updatedAt = data.valueForKey("updatedAt") as! String
    }
}
