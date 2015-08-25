//
//  LoginViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: BaseViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButtonRef: FBSDKLoginButton!
    @IBOutlet weak var udacityLoginButton: UIButton!
    
    var activeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButtonRef.readPermissions = ["public_profile"]
        
        loginButtonRef.layer.cornerRadius = 10
        udacityLoginButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil){
            showLoadingIndeterminate("Logging in...")
            getApiClient().loginWithFacebook(loginSuccess, onError: loginFailed)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        showLoadingIndeterminate("Logging in...")
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
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        showMessage(reason, message: details)
    }
    
    func proceedToNext(data: StudentBio!){
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        getApiClient().userInfo = data
        let mainViewController = storyboard!.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        navigationController!.presentViewController(mainViewController, animated: true, completion: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil) {
            showMessage("Error", message: "Login error. Please try again later")
        }
        else if result.isCancelled {
            showMessage("Cancelled", message: "Facebook request cancelled")
        }
        else {
            showLoadingIndeterminate("Logging in...")
            getApiClient().loginWithFacebook(loginSuccess, onError: loginFailed)
        }
    }
    
    /*func getUserFacebookData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "first_name, last_name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil){
                // Process error
                self.showMessage("Error", message: "Could not get account information")
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            } else {
                println("fetched user: \(result)")
                let userFName : NSString = result.valueForKey("first_name") as! NSString
                let userLName : NSString = result.valueForKey("last_name") as! NSString
                var bio = StudentBio()
                bio.firstName = userFName as! String
                bio.lastName = userLName as! String
                bio.isFacebook = true
                self.proceedToNext(bio)
            }
        })
    }*/
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
}
