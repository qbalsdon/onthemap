//
//  LoginViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
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
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        getApiClient().login(loginText.text, password: passwordText.text, onSuccess: loginSuccess, onError: loginFailed)
    }
    
    @IBAction func singUpPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    func loginSuccess(){
        getApiClient().getUserData(getApiClient().userKey, onSuccess: proceedToNext,
            onError: { (title: String!, message: String!) -> () in
                self.showMessage(title, message: message)
            }
        )
    }
    
    func loginFailed(reason: String!, details: String!){
        showMessage(reason, message: details)
    }
    
    func proceedToNext(data: StudentBio!){
        getApiClient().userInfo = data
        let mainViewController = storyboard!.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        navigationController!.presentViewController(mainViewController, animated: true, completion: nil)
    }
}
