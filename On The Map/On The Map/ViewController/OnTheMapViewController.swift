//
//  OnTheMapViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapViewController: TabBarViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func receiveLocations(Locations: [Location]) {
        let removeAnnotation = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(removeAnnotation)
        for loc in Locations{
            // Drop a pin
            mapView.addAnnotation(loc)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Location {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let infoButton = UIButton.buttonWithType(UIButtonType.InfoDark) as! UIButton
            pinAnnotationView.rightCalloutAccessoryView = infoButton
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? Location {
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }
}
