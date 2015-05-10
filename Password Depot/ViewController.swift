//
//  ViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/13/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var passwordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    let cellIdentifier = "cell"
    
    @IBAction func addNewPassword(sender: AnyObject) {
        print("TODO: add new password")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PasswordItem.getPasswordItemList().count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        if (cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        let imageForFinancial = UIImage(named: "star")
        let imageForOther = UIImage(named:"star2")
        if (PasswordItem.getPasswordItemList()[indexPath.row].id == "CIBC"){
            cell!.imageView?.image = imageForFinancial;
        }
        else{
            cell!.imageView?.image = imageForOther;
        }
        
        cell!.textLabel?.text = PasswordItem.getPasswordItemList()[indexPath.row].id
        cell!.detailTextLabel?.text = String(format:"%@ / %@", PasswordItem.getPasswordItemList()[indexPath.row].userName, PasswordItem.getPasswordItemList()[indexPath.row].password)
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDetailSegue") {
            var destinationController : PasswordDetailsViewController = segue.destinationViewController as! PasswordDetailsViewController;
            var passwordItem = PasswordItem.getPasswordItemList()[self.passwordTableView.indexPathForSelectedRow()!.row];
             destinationController.setPasswordItem(passwordItem);
        }
    }
    
    @IBAction func saveNewPassword(segue: UIStoryboardSegue) {
        println("from segue id: %@", segue.identifier);
         if (segue.identifier == "unwind") {
            var destinationController : CreatePasswordViewController = segue.sourceViewController  as! CreatePasswordViewController;
            var passwordItem = destinationController.newPassword
            if let pass = passwordItem{
                PasswordItem.addPasswordItem(pass)
                self.passwordTableView.reloadData()
            }
        }

    }
    
  /*  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowValue = PasswordItem.getPasswordItemList()[indexPath.row].id
    
        let controller = UIAlertController(title: rowValue,
                                message: "Copy the selected item to clipboard", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Username",
                                style: .Default, handler: nil)
        controller.addAction(action)
        
        let action2 = UIAlertAction(title: "Password",
                                style: .Default, handler: nil)
        controller.addAction(action2)
        presentViewController(controller, animated: true, completion: nil)
    }*/
}


