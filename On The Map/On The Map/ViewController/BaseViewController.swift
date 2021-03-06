//
//  BaseViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getApiClient() -> ApiClient {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.apiClient
    }

    //MARK: Alerts
    func showMessage(title: String!, message: String!){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Ok", style: .Cancel) { (action) -> Void in
        }
        
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showMessage(title: String!, message: String!, onEnd: () -> ()){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Ok", style: .Cancel) { (action) -> Void in
            onEnd()
        }
        
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showMessageWithTwoButtons(title: String!, message: String!, positiveText: String!, onSuccess: () -> ()){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
        }
        

        let positive = UIAlertAction(title: positiveText, style:.Default) { (action) -> Void in
            onSuccess()
        }
        
        alertController.addAction(positive)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MBProgressHUD
    func showLoadingIndeterminate(message: String!){
        let loadingNotification = MBProgressHUD.showHUDAddedTo(view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = message
    }
}
