//
//  Location.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject, MKAnnotation {
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
    
    var coordinate: CLLocationCoordinate2D{
        get {
            return CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
        }
    }
    
    var title: String{
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    var subtitle: String{
        get {
            return mediaURL
        }
    }
}
