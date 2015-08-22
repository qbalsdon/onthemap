//
//  LoginViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class LoginViewController: APIViewController {
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var activeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
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
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        login(loginText.text, password: passwordText.text, onSuccess: loginSuccess, onError: loginFailed)
    }
    
    func loginSuccess(sessionId: String!){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.SessionID = sessionId
        
        let mainViewController = storyboard!.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        navigationController!.presentViewController(mainViewController, animated: true, completion: nil)
    }
    
    func loginFailed(reason: String!, details: String!){
        showMessage(reason, message: details)
    }
}
