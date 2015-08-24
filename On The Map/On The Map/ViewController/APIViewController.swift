//
//  APIViewViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/22.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class APIViewController: BaseViewController {
    
    let POST = "POST"
    let GET = "GET"
    let PUT = "PUT"
    let DELETE = "DELETE"
    
    let UDACITY_BASE_URL = "https://www.udacity.com/api/"
    let PARSE_BASE_URL = "https://api.parse.com/1/classes/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Generic API
    func apiCall(baseUrl: String!, apiMethod: String!, httpMethod: String!, headers: NSDictionary!, httpBody: String!, onSuccess: (AnyObject!) -> (), onError: (String!, String!) -> ()){
        let stringUrl = baseUrl + apiMethod
        var urlStr : String = stringUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var url : NSURL = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = httpMethod
        
        if (headers != nil){
            for (key, value) in headers{
                request.addValue(value as? String, forHTTPHeaderField: key as! String)
            }
        }
        
        if (httpBody != nil){
            request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println("Error: \(response)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    onError("Connection Error",response.description)
                }
            }
            var newData = data
            
            if baseUrl == self.UDACITY_BASE_URL {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            }
        
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
    func login(username: String!, password: String!, onSuccess: (String!, String!, String!) -> (), onError: (String!, String!) -> ()){
        let loginHeaders = ["Accept" : "application/json", "Content-Type" : "application/json"]
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        apiCall(UDACITY_BASE_URL, apiMethod: "session", httpMethod: POST, headers: loginHeaders, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
                self.parseLogin(result, onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    //TODO: Use somehow??
    func getUserData(userKey: String!, onError: (String!, String!) -> ()){
        apiCall(UDACITY_BASE_URL, apiMethod: "users/" + userKey, httpMethod: GET, headers: nil, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
                self.parseUserData(result, onError: onError)
            }, onError: onError)
    }
    
    //MARK: Parse Functions
    func getUserLocations(onSuccess: ([Location]) -> (), onError: (String!, String!) -> ()){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers = ["X-Parse-Application-Id" : appDelegate.parseAppId, "X-Parse-REST-API-Key" : appDelegate.parseRestKey, "Accept" : "application/json"]
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation", httpMethod: GET, headers: headers, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
                self.parseLocations(result,onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    func postUserLocation(locationInfo: Location!, mapString: String!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers = ["X-Parse-Application-Id" : appDelegate.parseAppId, "X-Parse-REST-API-Key" : appDelegate.parseRestKey, "Accept" : "application/json"]
        let body = "{\"uniqueKey\": \"\(locationInfo.uniqueKey)\", \"firstName\": \"\(locationInfo.firstName)\", \"lastName\": \"\(locationInfo.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(locationInfo.mediaURL)\",\"latitude\": \(locationInfo.latitude), \"longitude\": \(locationInfo.longitude)}"
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation", httpMethod: POST, headers: headers, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
            if let createdAt = result.valueForKey("createdAt") as? String, let objectId = result.valueForKey("objectId") as? String{
                onSuccess()
                return
            }
            onError("Location not saved","Please try again later")
            }, onError: onError)
    }
    
    func updateUserLocation(locationInfo: Location!, mapString: String!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers = ["X-Parse-Application-Id" : appDelegate.parseAppId, "X-Parse-REST-API-Key" : appDelegate.parseRestKey, "Accept" : "application/json"]
        
        let body = "{\"uniqueKey\": \"\(locationInfo.uniqueKey)\", \"firstName\": \"\(locationInfo.firstName)\", \"lastName\": \"\(locationInfo.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(locationInfo.mediaURL)\",\"latitude\": \(locationInfo.latitude), \"longitude\": \(locationInfo.longitude)}"
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation/\(locationInfo.objectId)", httpMethod: PUT, headers: headers, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
            println(result)
            if let createdAt = result.valueForKey("updatedAt") as? String{
                onSuccess()
                return
            }
            onError("Location not saved","Please try again later")
            }, onError: onError)
    }
    
    func checkUserLocation(userKey: String!, onSuccess: (Bool!, String!) -> (), onError: (String!, String!) -> ()){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers = ["X-Parse-Application-Id" : appDelegate.parseAppId, "X-Parse-REST-API-Key" : appDelegate.parseRestKey]
        
        let whereClause = "where={\"uniqueKey\":\"\(userKey)\"}"//.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation?\(whereClause)", httpMethod: GET, headers: headers, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
                if let locationData = result.valueForKey("results") as? NSArray{
                    if locationData.count == 0{
                        onSuccess(false, nil)
                        return
                    }
                    onSuccess(true, locationData[0].valueForKey("objectId") as! String)
                }
                onSuccess(false, nil)
            }, onError: onError)
    }
    
    func deleteUserLocation(userKey: String!, onSuccess: (Bool!) -> (), onError: (String!, String!) -> ()){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers = ["X-Parse-Application-Id" : appDelegate.parseAppId, "X-Parse-REST-API-Key" : appDelegate.parseRestKey, "Accept" : "application/json"]
        
        let whereClause = "where={\"uniqueKey\":\"\(appDelegate.userKey)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation?\(whereClause)", httpMethod: DELETE, headers: headers, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
            if let locationData = result.valueForKey("results") as? NSArray{
                onSuccess(locationData.count > 0)
                return
            }
            onError("Location not deleted","Please try again later")
            }, onError: onError)
    }
    
    func logout(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = DELETE
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
    
    //MARK: Data parsing methods
    func parseLogin(parsedResult: AnyObject!, onSuccess: (String!, String!, String!) -> (), onError: (String!, String!) -> ()){
        if let status = parsedResult.valueForKey("status") as? Int{
            if status == 403{
                let reason = parsedResult.valueForKey("error") as! String
                onError("Login Error", reason)
                return
            }
        }
        if let loginSession = parsedResult.valueForKey("session") as? NSDictionary,
            accountDetail = parsedResult.valueForKey("account") as? NSDictionary {
                if let sessionId = loginSession["id"] as? String,
                    expiration = loginSession["expiration"] as? String,
                    keyValue = accountDetail["key"] as? String {
                        onSuccess(sessionId, keyValue, expiration)
                        return
                }
        }
        
        onError("Unknown Error", "Please try again");
    }
    
    func parseUserData(parsedResult: AnyObject!, onError: (String!, String!) -> ()){
        println("Data: \(parsedResult)")
    }
    
    func parseLocations(parsedResult: AnyObject!,onSuccess: ([Location]) -> (), onError: (String!, String!) -> ()){
        //println("Data: \(parsedResult)")
        
        var locationArray: [Location] = []
        
        if let locationData = parsedResult.valueForKey("results") as? NSArray{
            for (locationSet) in locationData{
                let location = Location()
                location.createdAt = locationSet.valueForKey("createdAt") as! String
                location.firstName = locationSet.valueForKey("firstName") as! String
                location.lastName = locationSet.valueForKey("lastName") as! String
                location.latitude = locationSet.valueForKey("latitude") as! NSNumber
                location.longitude = locationSet.valueForKey("longitude") as! NSNumber
                location.mapString = locationSet.valueForKey("mapString") as! String
                location.mediaURL = locationSet.valueForKey("mediaURL") as! String
                location.objectId = locationSet.valueForKey("objectId") as! String
                location.uniqueKey = locationSet.valueForKey("uniqueKey") as! String
                location.updatedAt = locationSet.valueForKey("updatedAt") as! String
                locationArray.append(location)
            }
            onSuccess(locationArray)
            return
        }
        
        onError("Unknown Error", "Please try again");
    }
}
