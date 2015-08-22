//
//  TabBarViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class TabBarViewController: APIViewController {

    override func viewWillAppear(animated: Bool) {
        var leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "cancelTapped:")
        navigationItem.setLeftBarButtonItems([leftAddBarButtonItem], animated: true)
        
    var addLocation:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: "pinTapped:")
        var refresh:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "cancelTapped:")
        navigationItem.setRightBarButtonItems([refresh, addLocation], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        getUserLocations(receiveLocations, onError: { (title: String!, message: String!) -> () in
            self.showMessage(title, message: message)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func receiveLocations(Locations: [Location]){
        preconditionFailure("Class does not override receiveLocations")
    }
    
    func pinTapped(sender: AnyObject!){
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("AddPinController") as! UIViewController
        navigationController!.presentViewController(nextVC, animated: true, completion: nil)
    }
}
