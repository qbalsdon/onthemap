//
//  Location.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var studentInfo : StudentInformation
    
    override init() {
        studentInfo = StudentInformation()
        super.init()
    }
    
    var coordinate: CLLocationCoordinate2D{
        get {
            return CLLocationCoordinate2DMake(studentInfo.latitude as! CLLocationDegrees, studentInfo.longitude as! CLLocationDegrees)
        }
    }
    
    var title: String{
        get {
            return "\(studentInfo.firstName) \(studentInfo.lastName)"
        }
    }
    
    var subtitle: String{
        get {
            return studentInfo.mediaURL
        }
    }
}
