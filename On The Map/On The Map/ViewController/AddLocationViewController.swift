//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/23.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    var location: LocationAnnotation!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    func setUpNavBar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        var leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped:")
        navigationItem.setRightBarButtonItems([leftAddBarButtonItem], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findButton.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        setUpNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func findButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("findLocationSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! LocationFinderViewController
        destination.oldLocation = location
        destination.locationText = locationTextField.text
    }
    
    func cancelTapped(sender: AnyObject!){
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
