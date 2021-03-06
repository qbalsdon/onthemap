//
//  LocationFinderViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/23.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class LocationFinderViewController: BaseViewController, UITextFieldDelegate {

    var locationText: String!
    var userLocation: LocationAnnotation!
    var oldLocation: LocationAnnotation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareLinkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    func setUpNavBar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        let leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped:")
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
        userLocation.studentInfo.mediaURL = shareLinkTextField.text
        userLocation.studentInfo.uniqueKey = getApiClient().userKey
        userLocation.studentInfo.mapString = locationText
        showLoadingIndeterminate("Uploading location")
        if oldLocation != nil {
            userLocation.studentInfo.objectId = oldLocation.studentInfo.objectId
            getApiClient().updateUserLocation(userLocation, onSuccess: success, onError: showError)
        } else {
            getApiClient().postUserLocation(userLocation, onSuccess: success, onError: showError)
        }
    }
    
    func cancelTapped(sender: AnyObject!){
        closeView()
    }
    
    //MARK: Helper methods
    func searchInMap(searchText : String!) {
        showLoadingIndeterminate("Finding location...")
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler {
            (response: MKLocalSearchResponse?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
            if error != nil{
                self.showMessage("Geocode Error", message: "Could not find location on the map", onEnd: {
                    () -> Void in
                        self.closeView()
                })
                return
            }
            if response!.mapItems.count > 0 {
                let firstLocation = response!.mapItems[0] 
                
                let span = MKCoordinateSpanMake(0.075, 0.075)
                let region = MKCoordinateRegion(center: firstLocation.placemark.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.userLocation = LocationAnnotation()
                self.userLocation.studentInfo.firstName = self.getApiClient().userInfo.firstName
                self.userLocation.studentInfo.lastName = self.getApiClient().userInfo.lastName
                self.userLocation.studentInfo.latitude = firstLocation.placemark.location!.coordinate.latitude
                self.userLocation.studentInfo.longitude = firstLocation.placemark.location!.coordinate.longitude
                self.mapView.addAnnotation(self.userLocation)
            }
        }
    }
    
    func success(){
        getApiClient().lastLocationSet = []
        closeView()
    }
    
    func closeView(){
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showError(reason: String!, details: String!){
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        showMessage(reason, message: details)
    }
}
