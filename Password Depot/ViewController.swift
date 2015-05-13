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
    
    override func viewDidAppear(animated: Bool) {
        self.passwordTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    let cellIdentifier = "password"
    
    @IBAction func addNewPassword(sender: AnyObject) {
        print("TODO: add new password")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PasswordItem.getPasswordItemList().count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? PasswordListItemCell
        
        let imageForFinancial = UIImage(named: "bee")
        let imageForOther = UIImage(named:"tip")
        if (PasswordItem.getPasswordItemList()[indexPath.row].id == "CIBC"){
            cell!.itemImage?.image = imageForFinancial;
        }
        else{
            cell!.itemImage?.image = imageForOther;
        }
        
        cell!.name?.text = PasswordItem.getPasswordItemList()[indexPath.row].id
        cell?.userName.setTitle( PasswordItem.getPasswordItemList()[indexPath.row].userName, forState: .Normal)
        
        cell!.password.setTitle( PasswordItem.getPasswordItemList()[indexPath.row].password, forState:.Normal)
        cell?.link.setTitle(PasswordItem.getPasswordItemList()[indexPath.row].link, forState: .Normal)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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
    
    @IBAction func onPasswordItemLinkClicked(sender: AnyObject) {
        var link : UIButton = sender as! UIButton;
        var urlString = link.titleLabel?.text;
        //open mobile safari on the link
        var url : NSURL? = NSURL(string: urlString!)
        var bOK = UIApplication.sharedApplication().openURL(url!)
        if (!bOK){
            var alert: UIAlertView  = UIAlertView (title: "Error", message: "Unable to open the URL, please check URL.", delegate: nil, cancelButtonTitle:"OK" )
            
            alert.show()
        }
    }
    
    @IBAction func onCopyUserIDClicked(sender: AnyObject) {
        var link : UIButton = sender as! UIButton;
        var urlString = link.titleLabel?.text;
        let pasteboard = UIPasteboard.generalPasteboard();
        pasteboard.string = urlString;
        showStatus("UserID copied to clipboard", timeout: 1)
    
    }
    @IBAction func onCopyPasswordClicked(sender: AnyObject) {
        var link : UIButton = sender as! UIButton;
        var urlString = link.titleLabel?.text;
        let pasteboard = UIPasteboard.generalPasteboard();
        pasteboard.string = urlString;
        showStatus("Password copied to clipboard", timeout: 1)

    }
    
    func showStatus(message : NSString, timeout: Double){
        var statusAlert = UIAlertView(title: nil, message: message as String, delegate: nil, cancelButtonTitle: "OK")
        statusAlert.show();
      //  NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: Selector("timerExpired:"), userInfo: statusAlert, repeats: true)
    }

    func timerExpired(timer : NSTimer){
    
        var statusAlert = timer.userInfo as! UIAlertView

        dispatch_async(dispatch_get_main_queue(),{
            println("dismissed")
            statusAlert.dismissWithClickedButtonIndex(0, animated: false)
            timer.invalidate()
        });
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
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
        let sourceViewController : PasswordDetailsViewController = sender.sourceViewController as! PasswordDetailsViewController
        if (sourceViewController.bDelete){
            PasswordItem.deletePasswordItem(sourceViewController.passwordItem!)
            self.passwordTableView!.reloadData()
        }
        
    // Pull any data from the view controller which initiated the unwind segue.
    }

    
}


