//
//  SweetsTableViewController.swift
//  Swiffer
//
//  Created by Kyle Lee on 4/8/16.
//  Copyright © 2016 Kilo Loco. All rights reserved.
//

import UIKit
import CloudKit

class SweetsTableViewController: UITableViewController {
    
    
    var sweets = [CKRecord]()
    var refresh: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(self.loadData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)

        self.loadData()
    }
    
    
    func loadData() {
        sweets = [CKRecord]()
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Sweet", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        publicData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
            guard let sweets = results else {
                print(error)
                return
            }
            
            self.sweets = sweets
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            })
        }
        
        
    }

    @IBAction func sendSweet(sender: AnyObject) {
        
        let alert = UIAlertController(title: "New Sweet", message: "Enter a Sweet", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.placeholder = "Your Sweet"
        }
        print("here")
        alert.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (action: UIAlertAction) in
            let textField = alert.textFields!.first!
            
            if textField.text != "" {
                let newSweet = CKRecord(recordType: "Sweet")
                newSweet["content"] = textField.text
                print("then here")
                let publicData = CKContainer.defaultContainer().publicCloudDatabase
                publicData.saveRecord(newSweet, completionHandler: { (record: CKRecord?, error: NSError?) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.tableView.beginUpdates()
                            self.sweets.insert(newSweet, atIndex: 0)
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        })
                    } else {
                        print(error)
                    }
                    
                })
                
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.sweets.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        if self.sweets.count == 0 {
            return cell
        }
        
        let sweet = sweets[indexPath.row]
        
        if let sweetContent = sweet["content"] as? String {
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormat.stringFromDate(sweet.creationDate!)
            
            cell.textLabel?.text = sweetContent
            cell.detailTextLabel?.text = dateString
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
