//
//  LocationFinderViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/23.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MapKit

class LocationFinderViewController: APIViewController, UITextFieldDelegate {

    var locationText: String!
    var userLocation: Location!
    var objectId: String!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareLinkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    func setUpNavBar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        var leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped:")
        leftAddBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.setRightBarButtonItems([leftAddBarButtonItem], animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchInMap(locationText)
        submitButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        setUpNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Events
    @IBAction func submitButtonPressed(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        userLocation.mediaURL = shareLinkTextField.text
        userLocation.uniqueKey = appDelegate.userKey
        userLocation.objectId = objectId
        if objectId != nil {
            updateUserLocation(userLocation, mapString: locationText, onSuccess: closeView, onError: showError)
        } else {
            postUserLocation(userLocation, mapString: locationText, onSuccess: closeView, onError: showError)
        }
    }
    
    func cancelTapped(sender: AnyObject!){
        closeView()
    }
    
    //MARK: Helper methods
    func searchInMap(searchText : String!) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler {
            (response: MKLocalSearchResponse!, error: NSError!) in
            
            if response.mapItems != nil && response.mapItems.count > 0 {
                let firstLocation = response.mapItems[0] as! MKMapItem
                
                var span = MKCoordinateSpanMake(0.075, 0.075)
                var region = MKCoordinateRegion(center: firstLocation.placemark.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.userLocation = Location()
                self.userLocation.firstName = "Quintin"
                self.userLocation.lastName = "Balsdon"
                self.userLocation.latitude = firstLocation.placemark.location.coordinate.latitude
                self.userLocation.longitude = firstLocation.placemark.location.coordinate.longitude
                self.mapView.addAnnotation(self.userLocation)
            }
        }
    }
    
    func closeView(){
        navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    func showError(reason: String!, details: String!){
        showMessage(reason, message: details)
    }
}
