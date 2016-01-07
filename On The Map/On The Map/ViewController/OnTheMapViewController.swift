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
    
    override func receiveLocations(locations: [LocationAnnotation]) {
        super.receiveLocations(locations)
        let removeAnnotation = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(removeAnnotation)
        for loc in locations{
            // Drop a pin
            mapView.addAnnotation(loc)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if annotation is LocationAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let infoButton = UIButton(type: UIButtonType.InfoDark)
            pinAnnotationView.rightCalloutAccessoryView = infoButton
            
            //Attempt to lazy load the user image data. The only issue is that the button does not actually refresh
            /*let imageButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            let locData = annotation as! LocationAnnotation
            
            getApiClient().getUserData(locData.studentInfo.uniqueKey, onSuccess: {
                (data: StudentBio!) -> () in
                    println("\(locData.title) \(data.imageUrl)")
                    self.downloadImage(data.imageUrl, button: imageButton)
                }, onError: showError)
            
            pinAnnotationView.leftCalloutAccessoryView = imageButton*/
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? LocationAnnotation {
            UIApplication.sharedApplication().openURL(NSURL(string: annotation.subtitle!)!)
        }
    }
    
    /*
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func downloadImage(urlString:String!, button: UIButton!){
        var url : NSURL = NSURL(string: urlString)!
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                button.setImage(UIImage(data: data!), forState: UIControlState.Normal)
            }
        }
    }

    func showError(reason: String!, details: String!){
        println("\(reason) \(details)")
    }
    */
}
