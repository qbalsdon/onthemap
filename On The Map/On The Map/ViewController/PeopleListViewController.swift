//
//  PeopleListViewController.swift
//  On The Map
//
//  Created by Quintin Balsdon on 2015/08/15.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class PeopleListViewController: TabBarViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userTable: UITableView!
    var dataSource: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func receiveLocations(Locations: [Location]) {
        dataSource = Locations
        userTable.reloadData()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! UITableViewCell
        let loc = dataSource[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = loc.title
        cell.imageView?.image = UIImage(named: "Pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = dataSource[indexPath.row] as Location
        println("Show: \(location.subtitle)")
    }
}
