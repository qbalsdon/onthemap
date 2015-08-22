//
//  BaseViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Alerts
    func showMessage(title: String!, message: String!){
        var searchTextField: UITextField?
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Ok", style: .Cancel) { (action) -> Void in
        }
        
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
