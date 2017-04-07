//
//  ViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/13/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import GoogleMobileAds
import UIKit
import MessageUI
import LocalAuthentication


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    @IBOutlet weak var passwordTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var searchResultController : UISearchController!
    @IBOutlet weak var categorySelector: UISegmentedControl!
    var currentCategory : String?
    var isViewComeFromBackground : Bool = false
    
    func showAlert(_ title: String, message: String, buttonTitle: String, handler:((UIAlertAction?) -> Void )!){
        //first show the warning message and then show the createpasscodealert againg
        let alertDlg : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction : UIAlertAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler:handler);
        
        alertDlg.addAction(okAction)
        self.present(alertDlg, animated: false, completion: nil)
    }
    
    func showCreatePasscodeAlert(_ bForCreatePasscode : Bool){//ask user to create the password file
        
        var createPasscodeDlg : UIAlertController = UIAlertController(title: NSLocalizedString("Create Passcode", comment:""), message: NSLocalizedString("Pleaes create your logon passcode before using the application", comment:""), preferredStyle: UIAlertControllerStyle.alert)
        
        if (!bForCreatePasscode){
            createPasscodeDlg = UIAlertController(title: NSLocalizedString("Change Passcode", comment:""), message: NSLocalizedString("Pleaes enter your old and new passcode", comment:""), preferredStyle: UIAlertControllerStyle.alert)
        }
        var oldPasscodeField : UITextField?
        var passwcodeField : UITextField?
        var confirmPasscodeField: UITextField?
        if (!bForCreatePasscode){
            createPasscodeDlg.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = NSLocalizedString("Old passcode", comment:"")
                textField.isSecureTextEntry = true
                oldPasscodeField = textField
            })
        }
        
        createPasscodeDlg.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("New passcode", comment:"")
            textField.isSecureTextEntry = true
            passwcodeField = textField
        })
        
        createPasscodeDlg.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("Confirm new passcode", comment:"")
            textField.isSecureTextEntry = true
            confirmPasscodeField = textField
        })
        
        let okAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: UIAlertActionStyle.default){  (alert) in
            let passcode = passwcodeField!.text
            let confirmPassCode = confirmPasscodeField!.text
            
            //validate old passcode first if not for creating
            if (!bForCreatePasscode){
                let oldPasscode = oldPasscodeField!.text
                
                let loaded = (UIApplication.shared.delegate as! AppDelegate).passwordManager.loadPasswordFile(oldPasscode!)
                if (!loaded){
                    //first show the warning message and then show the createpasscodealert againg
                    self.showAlert(NSLocalizedString("Warning", comment:""), message:NSLocalizedString("Invalid old passcode entered. Please try again.", comment:""), buttonTitle: NSLocalizedString("OK", comment:""), handler: {  (alert) in
                        self.showCreatePasscodeAlert(bForCreatePasscode)
                    })
                    return;
                }
                
            }
            
            if (passcode != confirmPassCode){
                //first show the warning message and then show the createpasscodealert againg
                self.showAlert(NSLocalizedString("warning", comment:""), message: NSLocalizedString("Passcode and confirm Passcode have different value. Please try again.", comment:""), buttonTitle: NSLocalizedString("OK", comment:""),handler: {  (alert) in
                    self.showCreatePasscodeAlert(bForCreatePasscode)
                })
            }
            else{
                if (bForCreatePasscode){
                    //create password file
                    (UIApplication.shared.delegate as! AppDelegate).passwordManager.createPasswordFile(passcode!)
                    self.passwordTableView.reloadData()
                }
                else{
                    (UIApplication.shared.delegate as! AppDelegate).passwordManager.changePassword(passcode!)
                }
            }
        }
        createPasscodeDlg.addAction(okAction)
        
        //change passcode is cancellable
        if (!bForCreatePasscode){
            let cancelAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: UIAlertActionStyle.default){ (alert) in}
            
            createPasscodeDlg.addAction(cancelAction)
        }
        
        self.present(createPasscodeDlg, animated: false, completion: nil)
    }
    
    
    func authenticateUserToLoadPasswordList(){
    
        print("authenticateUserToLoadPasswordList")
        
        //if touch id is enabled
        var authError : NSError?;
        let authContext = LAContext();
   
        if((UIApplication.shared.delegate as! AppDelegate).passwordManager.hasLastUsedEncrytionKey() &&
                     (authContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError))) {
                authContext.localizedFallbackTitle = NSLocalizedString("Enter Passcode", comment:"");
                authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("Log in with your touch ID", comment:""),
                          reply: {(success: Bool, error: Error?) -> Void in
                          
                         print("authenticateUserToLoadPasswordList callback called")
      
                    if success {
                               print("authenticateUserToLoadPasswordList callback success")
      
                            let loaded = (UIApplication.shared.delegate as! AppDelegate).passwordManager.loadPasswordFileWithLastUsedEncryptionKey();
                            if (loaded){
                                DispatchQueue.main.async {
                                    self.passwordTableView.reloadData();
                                }
                            }
                            else{
                                self.showAlert(NSLocalizedString("Warning", comment:""), message: NSLocalizedString("Fail to get passcode based on your Touch ID, please input the passcode", comment:""), buttonTitle: NSLocalizedString("OK", comment:""), handler: {(alert) in
                                        print("authenticateUserToLoadPasswordList callback success fail to load")
    
                                        self.authenticateUserToLoadPasswordList();
                                    }
                                );
                            }
                    } else {
                            switch error!._code {
                            case LAError.Code.authenticationFailed.rawValue:
                              
                                self.showAlert(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Touch ID authentication failed, please enter passcode to log in.", comment:""), buttonTitle: NSLocalizedString("OK",comment:""), handler: {(alert) in
                    
                                        self.showEnterPasscodeAlert();
                                    }
                                    );

                            case LAError.Code.userCancel.rawValue:
                               // message = nil;
                                        print("authenticateUserToLoadPasswordList callback error: user cancel")
    

                                self.showEnterPasscodeAlert();
                            case LAError.Code.systemCancel.rawValue:
                               // message = "Touch ID authentication failed, please enter passcode to log in."
                                print("authenticateUserToLoadPasswordList callback error: system cancel")
                                //self.authenticateUserToLoadPasswordList();
                            case LAError.Code.userFallback.rawValue:
                                //message = "User request to enter passcode"
                                 print("authenticateUserToLoadPasswordList callback error: user fallback")
                           
                                self.showEnterPasscodeAlert();
                            default:
                                   print("authenticateUserToLoadPasswordList callback error: default")
                     
                           //     message = "Touch ID authentication failed, please enter passcode to log in.";
                                self.showEnterPasscodeAlert();
                            
                        }
                   }
                } );
        }
        else{
            showEnterPasscodeAlert();
        }
    }
    
    func showEnterPasscodeAlert(){//ask user to enter the passcode
        let enterPasscodeDlg : UIAlertController = UIAlertController(title: NSLocalizedString("Enter Passcode", comment:""), message: NSLocalizedString("Pleaes enter passcode to log on", comment:""), preferredStyle: UIAlertControllerStyle.alert)
        var passwcodeField : UITextField?
        enterPasscodeDlg.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("passcode", comment:"")
            textField.isSecureTextEntry = true
            passwcodeField = textField
        })
        
        let okAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertActionStyle.default){  (alert) in
            let passcode = passwcodeField!.text
            
            let loaded = (UIApplication.shared.delegate as! AppDelegate).passwordManager.loadPasswordFile(passcode!)
            if (loaded){
                self.passwordTableView.reloadData()
            }
            else{
                self.showAlert(NSLocalizedString("Warning", comment:""), message: NSLocalizedString("The entered passcode is invalid, please try again",comment:""), buttonTitle: NSLocalizedString("OK", comment:""), handler: {(alert) in
                    print("ok pressed")
                    self.showEnterPasscodeAlert()}
                )
            }
        }
        
        enterPasscodeDlg.addAction(okAction)
        self.present(enterPasscodeDlg, animated: false, completion: nil)
    }
    
    var initialized  : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-4348078921501765/4004108337"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
  
        searchResultController = UISearchController(searchResultsController: nil)
        searchResultController.searchResultsUpdater = self
        searchResultController.searchBar.sizeToFit()
        self.passwordTableView.tableHeaderView = self.searchResultController.searchBar
        searchResultController.searchBar.delegate = self
        searchResultController.hidesNavigationBarDuringPresentation = false
        searchResultController.dimsBackgroundDuringPresentation = false // default is YES
        
        definesPresentationContext = true

  
        initialized = true;
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.passwordFileChanged(_:)),
            name: NSNotification.Name(rawValue: "passwordFileChanged"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.passwordFileUnloaded(_:)),
            name: NSNotification.Name(rawValue: "passwordFileUnloaded"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.appWillEnterForeground(_:)),
            name: NSNotification.Name(rawValue: "UIApplicationWillEnterForegroundNotification"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.appDidBecomeActive(_:)),
            name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),
            object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.InitializeViewBasedOnPasswordFileStatus()
    }
    
    @objc func passwordFileChanged(_ notification: Notification){
        self.passwordTableView.reloadData()
        self.viewDidLoad()
    }

    @objc func passwordFileUnloaded(_ notification: Notification){
        self.passwordTableView.reloadData()
    }
    
    @objc func appWillEnterForeground(_ notification: Notification){
        self.isViewComeFromBackground = true
    }
  
    @objc func appDidBecomeActive(_ notification: Notification){
        if (self.isViewComeFromBackground){
             self.isViewComeFromBackground = false;
             InitializeViewBasedOnPasswordFileStatus();
        }
    }
  
    
    
    func InitializeViewBasedOnPasswordFileStatus() {
        if ((UIApplication.shared.delegate as! AppDelegate).passwordManager.isPasswordFileExisting()){
            if (!(UIApplication.shared.delegate as! AppDelegate).passwordManager.isPasswordFileUnlocked()){
         
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let list =  (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text){
            return list.count;
        }
        else{
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PasswordListItemCell
        
        if ((UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].category == "Financial"){
            cell!.itemImage?.image = imageForFinancial;
        }
        else if ((UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].category == "Personal") {
            cell!.itemImage?.image = imageForPersonal;
        }
        else if ((UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].category == "Work") {
            cell!.itemImage?.image = imageForWork;
        }
        else{
            cell!.itemImage?.image = imageForOther;
        }
        
        cell!.name?.text = (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].id
       
        cell!.userName.setTitle( (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].userName, for: UIControlState())
        cell!.password.setTitle( (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].password, for:UIControlState())
        
        let linkUrl = (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(indexPath as NSIndexPath).row].link
        
        if ( linkUrl == nil ){
            cell!.link.isHidden = true
            cell!.textLabel?.text = nil
        }
        else{
            let nsurl : URL? = URL(string: linkUrl!)
            if (nsurl != nil && (nsurl!.host == nil || nsurl!.scheme == nil) ){
                cell!.link.isHidden = true
            }
            else{
                cell!.link.isHidden = false;
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetailSegue") {
            let destinationController : PasswordDetailsViewController = segue.destination as! PasswordDetailsViewController;
            let passwordItem = (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(currentCategory, searchResultController.searchBar.text)![(self.passwordTableView.indexPathForSelectedRow! as NSIndexPath).row];
            destinationController.setPasswordItem(passwordItem);
        }
        else if (segue.identifier == "newPassword"){
            let destinationController : PasswordDetailsViewController = segue.destination as! PasswordDetailsViewController;
            destinationController.bNewPassword = true
            destinationController.defaultCategoryForNewPassword = currentCategory
        }
    }
    
    @IBAction func onChangePasscode(_ sender: AnyObject) {
        showCreatePasscodeAlert(false)
    }
    
    
    @IBAction func onCopyUserIDClicked(_ sender: AnyObject) {
        let link : UIButton = sender as! UIButton;
        let urlString = link.titleLabel?.text;
        let pasteboard = UIPasteboard.general;
        pasteboard.string = urlString;
        showStatus("UserID copied to clipboard", timeout: 1)
        
    }
    @IBAction func onCopyPasswordClicked(_ sender: AnyObject) {
        let link : UIButton = sender as! UIButton;
        let urlString = link.titleLabel?.text;
        let pasteboard = UIPasteboard.general;
        pasteboard.string = urlString;
        showStatus("Password copied to clipboard", timeout: 1)
        
    }
    
    func showStatus(_ message : NSString, timeout: Double){
        let alertController = UIAlertController(title: nil, message: message as String, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .default) { (action) -> Void in
            print("The user is okay.")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
//        let statusAlert = UIAlertView(title: nil, message: message as String, delegate: nil, cancelButtonTitle: "OK")
  //      statusAlert.show();
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
    
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue)
    {
        let sourceViewController : PasswordDetailsViewController = sender.source as! PasswordDetailsViewController
        if (sourceViewController.bDelete){
            (UIApplication.shared.delegate as! AppDelegate).passwordManager.deletePasswordItem(sourceViewController.passwordItem!)
            (UIApplication.shared.delegate as! AppDelegate).passwordManager.savePasswordFile()
            
            self.passwordTableView!.reloadData()
        }
        else if ( sourceViewController.bUpdate){
            if (currentCategory != "All" && currentCategory != nil){
                updateCategoryByName(sourceViewController.passwordItem!.category!)
            }
            (UIApplication.shared.delegate as! AppDelegate).passwordManager.savePasswordFile()
            
            self.passwordTableView!.reloadData()
 
        }
        else if(sourceViewController.bNewPassword && !sourceViewController.bCancelled){
            _ = (UIApplication.shared.delegate as! AppDelegate).passwordManager.addPasswordItem(sourceViewController.passwordItem!)
            
            if (currentCategory != "All" && currentCategory != nil){
                updateCategoryByName(sourceViewController.passwordItem!.category!)
            }
            self.passwordTableView!.reloadData()
        }
        
        // Pull any data from the view controller which initiated the unwind segue.
    }
    @IBAction func onLogout(_ sender: AnyObject) {
        print("viewcontroller onlogout")
        (UIApplication.shared.delegate as! AppDelegate).passwordManager.unloadPasswordFile()
        self.passwordTableView!.reloadData()
//        self.authenticateUserToLoadPasswordList()
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)

    }
    
    
    
    //send the encrypted file to email
    @IBAction func onExport(_ sender: AnyObject) {
        
        if (MFMailComposeViewController.canSendMail()){
            let mailComposerVC = MFMailComposeViewController()
            
            
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            
            //mailComposerVC.setToRecipients([receipt])
            mailComposerVC.setSubject(NSLocalizedString("Data backup email from Password Booklet application", comment:""))
            mailComposerVC.setMessageBody(NSLocalizedString("To restore the backup file, click on the attachement and select Password Booklet application. WARNING: all existing data will be overwritten.", comment:""), isHTML: false)
            
            //load the password file data before decryption
            
            let data =  (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordFileContent()
            mailComposerVC.addAttachmentData(data as Data, mimeType: "passwordbooklet", fileName: "data.passwordbooklet")
            
            // Fill out the email body text
            self.present(mailComposerVC, animated: true, completion:nil)
        }
        else{
            let titleStr = NSLocalizedString("Error",comment:"")
            let msg1 = NSLocalizedString("Please first configure your email account",comment:"")
            let alertController = UIAlertController(title: titleStr, message: msg1, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .default) { (action) -> Void in
                print("The user is okay.")
             }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onOpenLink(_ sender: AnyObject) {
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
        
        let cell : PasswordListItemCell = superView as! PasswordListItemCell;
        
        //get the password name based on label
        let passwordID = cell.name.text
        
        //get password item based on id
        let item = (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemByID(passwordID!)
    
        let url : URL? = URL(string: item!.link!)
        let bOK = UIApplication.shared.openURL(url!)
        if (!bOK){
            let titleStr = NSLocalizedString("Error",comment:"")
            let msg1 = NSLocalizedString("Unable to open the URL of '",comment:"")
            let msg2 = NSLocalizedString("', please check the URL is value.", comment:"")
            let alertController = UIAlertController(title: titleStr, message: msg1 + item!.link! + msg2, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .default) { (action) -> Void in
                print("The user is okay.")
             }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCategorySelected(_ sender: AnyObject) {
        let seg : UISegmentedControl = sender as! UISegmentedControl
        let index = seg.selectedSegmentIndex
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
    
        self.passwordTableView.reloadData()
    }
    
    func updateCategoryByName(_ categoryName: String) {
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

    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar.text;
        self.passwordTableView.reloadData()
     
    }
}


