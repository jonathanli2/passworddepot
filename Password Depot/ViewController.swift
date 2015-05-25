//
//  ViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/13/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var passwordTableView: UITableView!
    
     func showCreatePasscodeAlert(bForCreatePasscode : Bool){//ask user to create the password file
     
            var createPasscodeDlg : UIAlertController = UIAlertController(title: "Create Passcode", message: "Pleaes set your logon passcode before using the application", preferredStyle: UIAlertControllerStyle.Alert)
        
            if (!bForCreatePasscode){
                createPasscodeDlg = UIAlertController(title: "Change Passcode", message: "Pleaes enter your new passcode", preferredStyle: UIAlertControllerStyle.Alert)
            }
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
        
            var okAction : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){  (alert) in
                var passcode = passwcodeField!.text
                var confirmPassCode = confirmPasscodeField!.text
                if (passcode == confirmPassCode){
                    if (bForCreatePasscode){
                        //create password file
                        (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.createPasswordFile(passcode)
                        self.passwordTableView.reloadData()
                    }
                    else{
                       (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.changePassword(passcode)
                    }

                }
                else{
                    self.showCreatePasscodeAlert(bForCreatePasscode)
                }
            }
             createPasscodeDlg.addAction(okAction)
        
        
            //change passcode is cancellable
            if (!bForCreatePasscode){
                var cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default){ (alert) in}

                createPasscodeDlg.addAction(cancelAction)
            }

            self.presentViewController(createPasscodeDlg, animated: false, completion: nil)
        }
 
        func showEnterPasscodeAlert(){//ask user to enter the passcode
            var enterPasscodeDlg : UIAlertController = UIAlertController(title: "Enter Passcode", message: "Pleaes enter passcode to log on", preferredStyle: UIAlertControllerStyle.Alert)
            var passwcodeField : UITextField?
            enterPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                        textField.placeholder = "passcode"
                        textField.secureTextEntry = true
                        passwcodeField = textField
                        })
            
            var okAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){  (alert) in
                var passcode = passwcodeField!.text
                
                var loaded = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.loadPasswordFile(passcode)
                if (loaded){
                    self.passwordTableView.reloadData()
                }
                else{
                    self.showEnterPasscodeAlert()
                }
            }
            
            enterPasscodeDlg.addAction(okAction)
            self.presentViewController(enterPasscodeDlg, animated: false, completion: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "passwordFileChanged:",
            name: "passwordFileChanged",
            object: nil)
        
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.isPasswordFileExisting()){
            //ask user to input passcode to load the password file
            self.showEnterPasscodeAlert()
        }
        else{
            //ask user to create the password file
            self.showCreatePasscodeAlert(true)
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
   /* override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "passwordFileChanged", object: nil)
    }
    */
    @objc func passwordFileChanged(notification: NSNotification){
        self.passwordTableView.reloadData()
        self.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.passwordTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    let cellIdentifier = "password"
    let imageForFinancial = UIImage(named: "financial")
    let imageForPersonal = UIImage(named:"personal")
    let imageForGeneral = UIImage(named:"general")
    
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
        
     
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].category == "Financial"){
            cell!.itemImage?.image = imageForFinancial;
        }
        else if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].category == "Personal") {
            cell!.itemImage?.image = imageForPersonal;
        }
        else{
            cell!.itemImage?.image = imageForGeneral;
        }
        
        cell!.name?.text = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].id
      //  cell!.userName.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].userName, forState: .Normal)
         cell!.userName.setTitle("ddd", forState: .Normal)
        cell!.password.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].password, forState:.Normal)
        cell!.link.setTitle((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList()![indexPath.row].link, forState: .Normal)
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
    
    @IBAction func onChangePasscode(sender: AnyObject) {
        showCreatePasscodeAlert(false)
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
    @IBAction func onLogout(sender: AnyObject) {
         (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.unloadPasswordFile()
         self.passwordTableView!.reloadData()
         self.showEnterPasscodeAlert()
    }


    
    //send the encrypted file to email
    @IBAction func onExport(sender: AnyObject) {
       
        
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            
            //mailComposerVC.setToRecipients([receipt])
            mailComposerVC.setSubject("Data backup email from Password Depot application")
            mailComposerVC.setMessageBody("To import the data back into the application, just open the attachement from your iphone's inbox application.", isHTML: false)
            
            //load the password file data before decryption
            
            var data =  (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordFileContent()
            mailComposerVC.addAttachmentData(data, mimeType: "passworddepot", fileName: "data.passworddepot")
        
            // Fill out the email body text
            self.presentViewController(mailComposerVC, animated: true, completion:nil)
        
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    
}


