//
//  ApiClient.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/24.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class ApiClient: NSObject {
    var session: NSURLSession!
    var userKey: String!
    
    var parseAppId: String!
    var parseRestKey: String!
    var facebookAppId: String!
    var lastLocationSet: [LocationAnnotation]!
    var userInfo: StudentBio!
    
    let POST = "POST"
    let GET = "GET"
    let PUT = "PUT"
    let DELETE = "DELETE"
    
    let UDACITY_BASE_URL = "https://www.udacity.com/api/"
    let PARSE_BASE_URL = "https://api.parse.com/1/classes/"
    
    override init(){
        session = NSURLSession.sharedSession()
        if let path = NSBundle.mainBundle().pathForResource("ApiKey", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            if let _ = keys {
                parseAppId = keys?["ParseApplicationId"] as? String
                parseRestKey = keys?["ParseRestApiKey"] as? String
                facebookAppId = keys?["FacebookAppId"] as? String
            }
        }
        userInfo = StudentBio()
        super.init()
    }
    
    //MARK: Generic API
    func apiCall(baseUrl: String!, apiMethod: String!, httpMethod: String!, httpBody: String!, onSuccess: (AnyObject!) -> (), onError: (String!, String!) -> ()){
        let stringUrl = baseUrl + apiMethod
        let urlStr : String = stringUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url : NSURL = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = httpMethod
        
        let headers = getHeaders(baseUrl, apiMethod: apiMethod, httpMethod: httpMethod)
        
        if (headers != nil){
            for (key, value) in headers{
                request.addValue((value as? String)!, forHTTPHeaderField: key as! String)
            }
        }
        
        if (httpBody != nil){
            request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    onError("Connection Error","Internet connectivity is down")
                }
                return
            }
            var newData = data
            
            if baseUrl == self.UDACITY_BASE_URL {
                newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            }
            
            var parsingError: NSError? = nil
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: NSJSONReadingOptions.AllowFragments)
            } catch error! as NSError {
                parsingError = error
                parsedResult = nil
            } catch {
                print("\(parsingError)")
                fatalError()
            }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                onSuccess(parsedResult)
            }
            return
        }
        task.resume()
    }
    
    //MARK: Get headers
    func getHeaders(URL: String!, apiMethod: String!, httpMethod: String!) -> NSDictionary! {
        if URL == UDACITY_BASE_URL {
            var headers = ["Accept" : "application/json", "Content-Type" : "application/json"]
            if apiMethod == "session" && httpMethod == DELETE{
                var xsrfCookie: NSHTTPCookie? = nil
                let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
                    if cookie.name == "XSRF-TOKEN" {
                        xsrfCookie = cookie
                    }
                }
                if let xsrfCookie = xsrfCookie {
                    headers["X-XSRF-TOKEN"] = xsrfCookie.value
                }

            }
            return headers
        }
        
        if URL == PARSE_BASE_URL {
            return ["X-Parse-Application-Id" : parseAppId, "X-Parse-REST-API-Key" : parseRestKey, "Accept" : "application/json"]
        }
        
        return nil
    }
    
    //MARK: Udacity Functions
    func login(body: String!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        apiCall(UDACITY_BASE_URL, apiMethod: "session", httpMethod: POST, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
            self.parseLogin(result, onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    func login(username: String!, password: String!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        login(body, onSuccess: onSuccess, onError: onError)
    }
    
    func loginWithFacebook(onSuccess: () -> (), onError: (String!, String!) -> ()){
        let body = "{\"facebook_mobile\": {\"access_token\": \"\(FBSDKAccessToken.currentAccessToken().tokenString);\"}}"
        login(body, onSuccess: onSuccess, onError: onError)
    }
    
    func getUserData(userKey: String!, onSuccess: (data: StudentBio!) -> (), onError: (String!, String!) -> ()){
        apiCall(UDACITY_BASE_URL, apiMethod: "users/" + userKey, httpMethod: GET, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
                self.parseUserData(result, onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    func logout(onSuccess: () -> (), onError: (String!, String!) -> ()){
        apiCall(UDACITY_BASE_URL, apiMethod: "session", httpMethod: DELETE, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
            print(result)
            if let session: AnyObject = result.valueForKey("session") as AnyObject!{
                onSuccess()
                return
            }
            onError("Error", "Connection problem: Unable to log out.")
            }, onError: onError)
    }
    
    //MARK: Parse Functions
    func getUserLocations(limit: Int32, skip: Int32, onSuccess: ([LocationAnnotation]) -> (), onError: (String!, String!) -> ()){
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation?limit=\(limit)&skip=\(skip)", httpMethod: GET, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
            self.parseLocations(result,onSuccess: onSuccess, onError: onError)
            }, onError: onError)
    }
    
    func postUserLocation(locationInfo: LocationAnnotation!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        let body = "{\"uniqueKey\": \"\(locationInfo.studentInfo.uniqueKey)\", \"firstName\": \"\(locationInfo.studentInfo.firstName)\", \"lastName\": \"\(locationInfo.studentInfo.lastName)\",\"mapString\": \"\(locationInfo.studentInfo.mapString)\", \"mediaURL\": \"\(locationInfo.studentInfo.mediaURL)\",\"latitude\": \(locationInfo.studentInfo.latitude), \"longitude\": \(locationInfo.studentInfo.longitude)}"
        
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation", httpMethod: POST, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
            if let createdAt = result.valueForKey("createdAt") as? String, let objectId = result.valueForKey("objectId") as? String{
                onSuccess()
                return
            }
            onError("Location not saved","Connection problem. Please try again later")
            }, onError: onError)
    }
    
    func updateUserLocation(locationInfo: LocationAnnotation!, onSuccess: () -> (), onError: (String!, String!) -> ()){
        let body = "{\"uniqueKey\": \"\(locationInfo.studentInfo.uniqueKey)\", \"firstName\": \"\(locationInfo.studentInfo.firstName)\", \"lastName\": \"\(locationInfo.studentInfo.lastName)\",\"mapString\": \"\(locationInfo.studentInfo.mapString)\", \"mediaURL\": \"\(locationInfo.studentInfo.mediaURL)\",\"latitude\": \(locationInfo.studentInfo.latitude), \"longitude\": \(locationInfo.studentInfo.longitude)}"
        
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation/\(locationInfo.studentInfo.objectId)", httpMethod: PUT, httpBody: body, onSuccess: {
            (result: AnyObject!) -> Void in
            if let createdAt = result.valueForKey("updatedAt") as? String{
                onSuccess()
                return
            }
            onError("Location not saved","Connection Problem. Please try again later")
            }, onError: onError)
    }
    
    func checkUserLocation(onSuccess: (Bool!, LocationAnnotation!) -> (), onError: (String!, String!) -> ()){
        
        let whereClause = "where={\"uniqueKey\":\"\(userKey)\"}"//.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation?\(whereClause)", httpMethod: GET, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
            if let locationData = result.valueForKey("results") as? NSArray{
                if locationData.count == 0{
                    onSuccess(false, nil)
                    return
                }
                onSuccess(true, self.parseLocationData(locationData[0]))
            }
            onSuccess(false, nil)
            }, onError: onError)
    }
    
    func deleteUserLocation(userKey: String!, onSuccess: (Bool!) -> (), onError: (String!, String!) -> ()){
        let whereClause = "where={\"uniqueKey\":\"\(userKey)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        apiCall(PARSE_BASE_URL, apiMethod: "StudentLocation?\(whereClause)", httpMethod: DELETE, httpBody: nil, onSuccess: {
            (result: AnyObject!) -> Void in
            if let locationData = result.valueForKey("results") as? NSArray{
                onSuccess(locationData.count > 0)
                return
            }
            onError("Location not deleted","Connection problem. Please try again later")
            }, onError: onError)
    }
    
    //MARK: Data parsing methods
    func parseLogin(parsedResult: AnyObject!, onSuccess: () -> (), onError: (String!, String!) -> ()){
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
                        self.userKey = keyValue
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let date = dateFormatter.dateFromString(expiration)
                        
                        var prop = [String: AnyObject]()
                        prop[NSHTTPCookieName] = "XSRF-TOKEN"
                        prop[NSHTTPCookieValue] = sessionId
                        prop[NSHTTPCookieDomain] = UDACITY_BASE_URL
                        prop[NSHTTPCookiePath] = "session"
                        prop[NSHTTPCookieVersion] = NSNumber(integer: 1)
                        prop[NSHTTPCookieExpires] = date!
                        
                        
                        let cookie = NSHTTPCookie(properties: prop)
                        
                        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)
                        
                        onSuccess()
                        return
                }
        }
        
        onError("Unknown Error", "Please try again");
    }
    
    func parseUserData(parsedResult: AnyObject!,onSuccess: (data: StudentBio!) -> (), onError: (String!, String!) -> ()){
        let info = parseBioData(parsedResult)
        if info == nil {
            onError("Error", "Could not get user details. Please try again")
        } else {
            onSuccess(data: info)
        }
    }
    
    func parseBioData(parsedResult: AnyObject!) -> StudentBio! {
        if let user = parsedResult.valueForKey("user") as? NSDictionary {
            var bio: StudentBio = StudentBio()
            
            let fUrl = user.valueForKey("_image_url") as! String
            
            bio.imageUrl = "http:\(fUrl)"
            if let fname = user.valueForKey("first_name") as? String, let lname = user.valueForKey("last_name") as? String {
                bio.firstName = fname
                bio.lastName = lname
            }
            return bio;
        }
        
        return nil
    }
    
    func parseLocationData(data: AnyObject!) -> LocationAnnotation {
        let location = LocationAnnotation()
        location.studentInfo = StudentInformation(data: data as! NSDictionary)
        return location
    }
    
    func parseLocations(parsedResult: AnyObject!,onSuccess: ([LocationAnnotation]) -> (), onError: (String!, String!) -> ()){
        //println("Data: \(parsedResult)")
        
        var locationArray: [LocationAnnotation] = []
        
        if let locationData = parsedResult.valueForKey("results") as? NSArray{
            for (locationSet) in locationData{
                locationArray.append(parseLocationData(locationSet))
            }
            onSuccess(locationArray)
            return
        }
        
        onError("Unknown Error", "Please try again");
    }
}
