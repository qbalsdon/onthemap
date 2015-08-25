//
//  TabBarViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class TabBarViewController: BaseViewController {
    
    override func viewWillAppear(animated: Bool) {
        var leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout:")
        navigationItem.setLeftBarButtonItems([leftAddBarButtonItem], animated: true)
        
        var addLocation:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: "pinTapped:")
        var refreshButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh")
        navigationItem.setRightBarButtonItems([refreshButton, addLocation], animated: true)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        showLoadingIndeterminate("Downloading Locations")
        getApiClient().getUserLocations(100, skip: 0, onSuccess: receiveLocations, onError: { (title: String!, message: String!) -> () in
            self.showMessage(title, message: message)
        })
    }
    
    func receiveLocations(Locations: [LocationAnnotation]){
        preconditionFailure("Class does not override receiveLocations")
    }
    
    func pinTapped(sender: AnyObject!){
        
        getApiClient().checkUserLocation(
            {
                (exists: Bool!, location: LocationAnnotation!) -> () in
                if  !exists {
                    self.addPin(nil)
                } else {
                    self.checkWantToAdd(location)
                }
            },
            onError: { (title: String!, message: String!) -> () in
                self.showMessage(title, message: message)
            }
        )
    }
    
    func logout(sender: AnyObject!){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        getApiClient().logout(closeView, onError: showMessage)        
    }
    
    func closeView(){
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkWantToAdd(location: LocationAnnotation!){
        showMessageWithTwoButtons("User location found", message: "Would you like to overwrite your location?", positiveText: "Yes", onSuccess: {
            () -> () in
                self.addPin(location)
        })
    }
    
    func addPin(location: LocationAnnotation!){
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("AddPinController") as! UINavigationController
        let addLoc = nextVC.viewControllers[0] as! AddLocationViewController
        addLoc.location = location
        navigationController!.presentViewController(nextVC, animated: true, completion: nil)
    }
}
