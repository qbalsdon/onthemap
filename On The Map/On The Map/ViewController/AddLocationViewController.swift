//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/23.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class AddLocationViewController: BaseViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        findButton.layer.cornerRadius = 10
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        // Do any additional setup after loading the view.
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

    @IBAction func findButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("findLocationSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "findLocationSegue"{
            let destination = segue.destinationViewController as! LocationFinderViewController
            destination.locationText = locationTextField.text
        }
    }
}
