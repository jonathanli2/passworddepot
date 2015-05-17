//
//  ViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/13/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var passwordTableView: UITableView!
    
     func showAlert(){//ask user to create the password file
            var createPasscodeDlg : UIAlertController = UIAlertController(title: "Create Passcode", message: "Pleaes set your logon passcode before using the application", preferredStyle: UIAlertControllerStyle.Alert)
            var passwcodeField : UITextField?
            var confirmPasscodeField: UITextField?
            createPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                        textField.placeholder = "passcode"
                        textField.secureTextEntry = true
                        passwcodeField = textField
                        })
            
            createPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                        textField.placeholder = "confirm Passcode"
                        textField.secureTextEntry = true
                        confirmPasscodeField = textField
                        })
            
            var okAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){  (alert) in
                var passcode = passwcodeField!.text
                var confirmPassCode = confirmPasscodeField!.text
                if (passcode == confirmPassCode){
                    //create password file
                    (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.createPasswordFile(passcode)
                }
                else{
                    self.showAlert()
                }
            }
            
            createPasscodeDlg.addAction(okAction)
            self.presentViewController(createPasscodeDlg, animated: false, completion: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.isPasswordFileExisting()){
            //ask user to input passcode to load the password file
        }
        else{
            //ask user to create the password file
            self.showAlert()
            
        }
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
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let list =  (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(){
            return list.count;
        }
        else{
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? PasswordListItemCell
        
        let imageForFinancial = UIImage(named: "bee")
        let imageForOther = UIImage(named:"tip")
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].id == "CIBC"){
            cell!.itemImage?.image = imageForFinancial;
        }
        else{
            cell!.itemImage?.image = imageForOther;
        }
        
        cell!.name?.text = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].id
        cell?.userName.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].userName, forState: .Normal)
        
        cell!.password.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].password, forState:.Normal)
        cell?.link.setTitle((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].link, forState: .Normal)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDetailSegue") {
            var destinationController : PasswordDetailsViewController = segue.destinationViewController as! PasswordDetailsViewController;
            var passwordItem = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![self.passwordTableView.indexPathForSelectedRow()!.row];
             destinationController.setPasswordItem(passwordItem);
        }
        else if (segue.identifier == "newPassword"){
            var destinationController : PasswordDetailsViewController = segue.destinationViewController as! PasswordDetailsViewController;
            destinationController.bNewPassword = true
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
    
     
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
        let sourceViewController : PasswordDetailsViewController = sender.sourceViewController as! PasswordDetailsViewController
        if (sourceViewController.bDelete){
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.deletePasswordItem(sourceViewController.passwordItem!)
            self.passwordTableView!.reloadData()
        }
        else if(sourceViewController.bNewPassword && !sourceViewController.bCancelled){
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.addPasswordItem(sourceViewController.passwordItem!)
            self.passwordTableView!.reloadData()
        }
        
    // Pull any data from the view controller which initiated the unwind segue.
    }

    
}


