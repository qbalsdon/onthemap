//
//  APIViewViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class APIViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Generic API
    func apiCall(urlString: String!, httpMethod: String!, headers: NSArray!, httpBody: String!, onSuccess: (AnyObject!) -> (), onError: (String!, String!) -> ()){
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = httpMethod
        
        for (headerValue) in headers{
            request.addValue("application/json", forHTTPHeaderField: headerValue as! String)
        }
        
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println("Error: \(response)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    onError("Connection Error",response.description)
                }
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            var parsingError: NSError? = nil
            let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                onSuccess(parsedResult)
            }
            return
        }
        task.resume()
    }
    
    //MARK: Udacity Functions
    func login(username: String!, password: String!, onSuccess: (String!) -> (), onError: (String!, String!) -> ()){
        let loginHeaders = ["Accept", "Content-Type"]
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        apiCall("https://www.udacity.com/api/session", httpMethod: "POST", headers: loginHeaders, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
                self.parseLogin(result, onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    func parseLogin(parsedResult: AnyObject!, onSuccess: (String!) -> (), onError: (String!, String!) -> ()){
        if let status = parsedResult.valueForKey("status") as? Int{
            if status == 403{
                let reason = parsedResult.valueForKey("error") as! String
                onError("Login Error", reason)
                return
            }
        }
        
        if let loginSession = parsedResult.valueForKey("session") as? NSDictionary{
            if let sessionId = loginSession["id"] as? String{
                onSuccess(sessionId)
                return
            }
        }
        
        onError("Unknown Error", "Please try again");
    }
    
    func logout(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
    }
}
