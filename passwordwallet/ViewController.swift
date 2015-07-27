//
//  ViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/13/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit
import MessageUI
import LocalAuthentication

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var passwordTableView: UITableView!
    
    @IBOutlet weak var categorySelector: UISegmentedControl!
    var currentCategory : String?
    var isViewComeFromBackground : Bool = false
    
    func showAlert(title: String, message: String, buttonTitle: String, handler:((UIAlertAction!) -> Void )!){
        //first show the warning message and then show the createpasscodealert againg
        var alertDlg : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        var okAction : UIAlertAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:handler);
        
        alertDlg.addAction(okAction)
        self.presentViewController(alertDlg, animated: false, completion: nil)
    }
    
    func showCreatePasscodeAlert(bForCreatePasscode : Bool){//ask user to create the password file
        
        var createPasscodeDlg : UIAlertController = UIAlertController(title: "Create Passcode", message: "Pleaes create your logon passcode before using the application", preferredStyle: UIAlertControllerStyle.Alert)
        
        if (!bForCreatePasscode){
            createPasscodeDlg = UIAlertController(title: "Change Passcode", message: "Pleaes enter your old and new passcode", preferredStyle: UIAlertControllerStyle.Alert)
        }
        var oldPasscodeField : UITextField?
        var passwcodeField : UITextField?
        var confirmPasscodeField: UITextField?
        if (!bForCreatePasscode){
            createPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Old passcode"
                textField.secureTextEntry = true
                oldPasscodeField = textField
            })
        }
        
        createPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "New passcode"
            textField.secureTextEntry = true
            passwcodeField = textField
        })
        
        createPasscodeDlg.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Confirm new passcode"
            textField.secureTextEntry = true
            confirmPasscodeField = textField
        })
        
        var okAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){  (alert) in
            var passcode = passwcodeField!.text
            var confirmPassCode = confirmPasscodeField!.text
            
            //validate old passcode first if not for creating
            if (!bForCreatePasscode){
                var oldPasscode = oldPasscodeField!.text
                
                var loaded = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.loadPasswordFile(oldPasscode)
                if (!loaded){
                    //first show the warning message and then show the createpasscodealert againg
                    self.showAlert("Warning", message:"Invalid old passcode entered. Please try again.", buttonTitle: "OK", handler: {  (alert) in
                        self.showCreatePasscodeAlert(bForCreatePasscode)
                    })
                    return;
                }
                
            }
            
            if (passcode != confirmPassCode){
                //first show the warning message and then show the createpasscodealert againg
                self.showAlert("warning", message: "Passcode and confirm Passcode have different value. Please try again.", buttonTitle: "OK",handler: {  (alert) in
                    self.showCreatePasscodeAlert(bForCreatePasscode)
                })
            }
            else{
                if (bForCreatePasscode){
                    //create password file
                    (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.createPasswordFile(passcode)
                    self.passwordTableView.reloadData()
                }
                else{
                    (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.changePassword(passcode)
                }
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
    
    
    func authenticateUserToLoadPasswordList(){
    
        println("authenticateUserToLoadPasswordList")
        
        //if touch id is enabled
        var authError : NSError?;
        var authContext = LAContext();
        if((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.hasLastUsedEncrytionKey() &&
                     (authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError))) {
                     authContext.localizedFallbackTitle = "Enter Passcode";
                authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in with your touch ID",
                          reply: {(success: Bool, error: NSError!) -> Void in
                          
                         println("authenticateUserToLoadPasswordList callback called")
      
                    if success {
                               println("authenticateUserToLoadPasswordList callback success")
      
                            var loaded = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.loadPasswordFileWithLastUsedEncryptionKey();
                            if (loaded){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.passwordTableView.reloadData();
                                }
                            }
                            else{
                                self.showAlert("Warning", message: "Fail to get passcode based on your Touch ID, please input the passcode", buttonTitle: "OK", handler: {(alert) in
                                        println("authenticateUserToLoadPasswordList callback success fail to load")
    
                                        self.authenticateUserToLoadPasswordList();
                                    }
                                );
                            }
                    } else {
                            var message : String?;
                            switch error!.code {
                            case LAError.AuthenticationFailed.rawValue:
                              
                                self.showAlert("Warning", message: "Touch ID authentication failed, please enter passcode to log in.", buttonTitle: "OK", handler: {(alert) in
                    
                                        self.showEnterPasscodeAlert();
                                    }
                                    );

                            case LAError.UserCancel.rawValue:
                               // message = nil;
                                        println("authenticateUserToLoadPasswordList callback error: user cancel")
    

                                self.showEnterPasscodeAlert();
                            case LAError.SystemCancel.rawValue:
                               // message = "Touch ID authentication failed, please enter passcode to log in."
                                println("authenticateUserToLoadPasswordList callback error: system cancel")
                                //self.authenticateUserToLoadPasswordList();
                            case LAError.UserFallback.rawValue:
                                //message = "User request to enter passcode"
                                 println("authenticateUserToLoadPasswordList callback error: user fallback")
                           
                                self.showEnterPasscodeAlert();
                            default:
                                   println("authenticateUserToLoadPasswordList callback error: default")
                     
                                message = "Touch ID authentication failed, please enter passcode to log in.";
                                self.showEnterPasscodeAlert();
                            
                        }
                   }
                });
        }
        else{
            showEnterPasscodeAlert();
        }
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
                self.showAlert("Warning", message: "The entered passcode is invalid, please try again", buttonTitle: "OK", handler: {(alert) in
                    println("ok pressed")
                    self.showEnterPasscodeAlert()}
                )
            }
        }
        
        enterPasscodeDlg.addAction(okAction)
        self.presentViewController(enterPasscodeDlg, animated: false, completion: nil)
    }
    
    var initialized  : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true

        initialized = true;
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "passwordFileChanged:",
            name: "passwordFileChanged",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "passwordFileUnloaded:",
            name: "passwordFileUnloaded",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "appWillEnterForeground:",
            name: "UIApplicationWillEnterForegroundNotification",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "appWDidBecomeActive:",
            name: "UIApplicationDidBecomeActiveNotification",
            object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        self.InitializeViewBasedOnPasswordFileStatus()
    }
    
    @objc func passwordFileChanged(notification: NSNotification){
        self.passwordTableView.reloadData()
        self.viewDidLoad()
    }

    @objc func passwordFileUnloaded(notification: NSNotification){
        self.passwordTableView.reloadData()
    }
    
    @objc func appWillEnterForeground(notification: NSNotification){
        self.isViewComeFromBackground = true
    }
  
    @objc func appWDidBecomeActive(notification: NSNotification){
        if (self.isViewComeFromBackground){
             self.isViewComeFromBackground = false;
             InitializeViewBasedOnPasswordFileStatus();
        }
    }
  
    
    
    func InitializeViewBasedOnPasswordFileStatus() {
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.isPasswordFileExisting()){
            if (!(UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.isPasswordFileUnlocked()){
         
                //ask user to input passcode to load the password file
                self.authenticateUserToLoadPasswordList()
            }
        }
        else{
            //ask user to create the password file
            self.showCreatePasscodeAlert(true)
            
        }

     //   self.passwordTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let cellIdentifier = "password"
    let imageForFinancial = UIImage(named: "Financial")
    let imageForPersonal = UIImage(named:"Personal")
    let imageForOther = UIImage(named:"Others")
    // let imageForSchool = UIImage(named:"School")
    let imageForWork = UIImage(named:"Work")
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let list =  (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory){
            return list.count;
        }
        else{
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? PasswordListItemCell
        
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].category == "Financial"){
            cell!.itemImage?.image = imageForFinancial;
        }
        else if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].category == "Personal") {
            cell!.itemImage?.image = imageForPersonal;
        }
        else if ((UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].category == "Work") {
            cell!.itemImage?.image = imageForWork;
        }
        else{
            cell!.itemImage?.image = imageForOther;
        }
        
        cell!.name?.text = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].id
        println( cell!.name?.text )
 
        cell!.userName.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].userName, forState: .Normal)
        cell!.password.setTitle( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].password, forState:.Normal)
        
        var linkUrl = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![indexPath.row].link
        
        if ( linkUrl == nil ){
            cell!.link.hidden = true
            cell!.textLabel?.text = nil
        }
        else{
            var nsurl : NSURL? = NSURL(string: linkUrl!)
            if (nsurl?.host == nil || nsurl?.scheme == nil ){
                cell!.link.hidden = true
            }
            else{
                cell!.link.hidden = false;
            }
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDetailSegue") {
            var destinationController : PasswordDetailsViewController = segue.destinationViewController as! PasswordDetailsViewController;
            var passwordItem = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)![self.passwordTableView.indexPathForSelectedRow()!.row];
            destinationController.setPasswordItem(passwordItem);
        }
        else if (segue.identifier == "newPassword"){
            var destinationController : PasswordDetailsViewController = segue.destinationViewController as! PasswordDetailsViewController;
            destinationController.bNewPassword = true
            destinationController.defaultCategoryForNewPassword = currentCategory
        }
    }
    
    @IBAction func onChangePasscode(sender: AnyObject) {
        showCreatePasscodeAlert(false)
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
    
  /*  func timerExpired(timer : NSTimer){
        
        var statusAlert = timer.userInfo as! UIAlertView
        
        dispatch_async(dispatch_get_main_queue(),{
            println("dismissed")
            statusAlert.dismissWithClickedButtonIndex(0, animated: false)
            timer.invalidate()
        });
    }
    */
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
        let sourceViewController : PasswordDetailsViewController = sender.sourceViewController as! PasswordDetailsViewController
        if (sourceViewController.bDelete){
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.deletePasswordItem(sourceViewController.passwordItem!)
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.savePasswordFile()
            
            self.passwordTableView!.reloadData()
        }
        else if ( sourceViewController.bUpdate){
            if (currentCategory != "All" && currentCategory != nil){
                updateCategoryByName(sourceViewController.passwordItem!.category!)
            }
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.savePasswordFile()
        }
        else if(sourceViewController.bNewPassword && !sourceViewController.bCancelled){
            (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.addPasswordItem(sourceViewController.passwordItem!)
            
            if (currentCategory != "All" && currentCategory != nil){
                updateCategoryByName(sourceViewController.passwordItem!.category!)
            }
            self.passwordTableView!.reloadData()
        }
        
        // Pull any data from the view controller which initiated the unwind segue.
    }
    @IBAction func onLogout(sender: AnyObject) {
        println("viewcontroller onlogout")
        (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.unloadPasswordFile()
        self.passwordTableView!.reloadData()
//        self.authenticateUserToLoadPasswordList()
        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)

    }
    
    
    
    //send the encrypted file to email
    @IBAction func onExport(sender: AnyObject) {
        
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients([receipt])
        mailComposerVC.setSubject("Data backup email from Password Booklet application")
        mailComposerVC.setMessageBody("To restore the backup file, click on the attachement and select Password Booklet application. WARNING: all existing data will be overwritten.", isHTML: false)
        
        //load the password file data before decryption
        
        var data =  (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordFileContent()
        mailComposerVC.addAttachmentData(data, mimeType: "passwordbooklet", fileName: "data.passwordbooklet")
        
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
    
    @IBAction func onOpenLink(sender: AnyObject) {
        let linkButton : UIButton = sender as! UIButton
        var superView = linkButton.superview
        while (true){
            if (superView is UITableViewCell){
                break;
            }
            else{
                superView = superView?.superview
            }
        }
        
        var cell : PasswordListItemCell = superView as! PasswordListItemCell;
        
        //get the password name based on label
        var passwordID = cell.name.text
        
        //get password item based on id
        var item = (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemByID(passwordID!)
    
        var url : NSURL? = NSURL(string: item!.link!)
        var bOK = UIApplication.sharedApplication().openURL(url!)
        if (!bOK){
            var alert: UIAlertView  = UIAlertView (title: "Error", message: "Unable to open the URL of '" + item!.link! + "', please check the URL is value.", delegate: nil, cancelButtonTitle:"OK" )
            
            alert.show()
        }
    }
    
    @IBAction func onCategorySelected(sender: AnyObject) {
        var seg : UISegmentedControl = sender as! UISegmentedControl
        var index = seg.selectedSegmentIndex
        switch (index){

            case 1:
            currentCategory = "Personal"
            break
            case 2:
            currentCategory = "Work"
            break
            case 3:
            currentCategory = "Financial"
            break
            case 4:
            currentCategory = "Others"
            break
            default:
            currentCategory = ""
            break
        }
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory)
        self.passwordTableView.reloadData()
    }
    
    func updateCategoryByName(categoryName: String) {
        var categoryIndex = 1;
        
        switch (categoryName){
            
        case "Personal":
            categoryIndex = 1;
            break
        case "Work":
            categoryIndex = 2;
            break
        case "Financial":
            categoryIndex = 3;
            break
        case "Others":
            categoryIndex = 4;
            break
        default:
            categoryIndex = 1
            break
        }
        self.categorySelector.selectedSegmentIndex = categoryIndex
        self.currentCategory = categoryName
    }

    
}


