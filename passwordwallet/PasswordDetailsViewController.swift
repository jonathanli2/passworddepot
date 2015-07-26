//
//  PasswordDetailsViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/15/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit
import iAd

class PasswordDetailsViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var passwordItem : PasswordItem?
    var bDelete: Bool = false
    var bUpdate: Bool = false
    var bNewPassword: Bool = false
    var bCancelled = false
    var defaultCategoryForNewPassword : String?
    let imageForFinancial = UIImage(named: "Financial")
    let imageForPersonal = UIImage(named:"Personal")
    let imageForWork = UIImage(named:"Work")
    //   let imageForSchool = UIImage(named:"School")
    let imageForOther = UIImage(named:"Others")
    
    func setPasswordItem(item:PasswordItem){
        self.passwordItem = item ;
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func showAlert(title: String, message: String, buttonTitle: String, handler:((UIAlertAction!) -> Void )!){
        //first show the warning message and then show the createpasscodealert againg
        var alertDlg : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        var okAction : UIAlertAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:handler);
        
        alertDlg.addAction(okAction)
        self.presentViewController(alertDlg, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        
        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: "cancel:",
                name: "UIApplicationDidEnterBackgroundNotification",
                object: nil)

        
        //if passwordItem is null, then it is for adding new password, otherwise it is for updating existing item
        if ( bNewPassword == true){
            self.navigationItem.title = "New Password"
            
            var leftButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:"cancel:");
            leftButton.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = leftButton
            
            var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action:"save:");
            rightButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = rightButton
            if (defaultCategoryForNewPassword == nil){
                defaultCategoryForNewPassword = "Personal"
            }
            passwordItem = PasswordItem(id: "", userName: "", password: "", link: "https://", note: "", category:defaultCategoryForNewPassword!)
            
        }
        else{
            self.title = passwordItem?.id
            // Do any additional setup after loading the view.
            var leftButton : UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action:"cancel:");
            leftButton.tintColor = UIColor.whiteColor()

            self.navigationItem.leftBarButtonItem = leftButton
            
            var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action:"deleteItem:");
            rightButton.tintColor = UIColor.whiteColor()

            self.navigationItem.rightBarButtonItem = rightButton
        }
        
        
    }
    
    func deleteItem(sender: UIBarButtonItem) {
        if (self.navigationItem.rightBarButtonItem?.title == "Save"){
            bUpdate = true;
            for (var index = 0; index < 5; index++) {
                var indexPath = NSIndexPath(forRow: index, inSection: 0 )
                if ( index < 4){
                    var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EditItemCell
                    if (index == 0){
                        passwordItem?.userName = cell.txtValue!.text
                    }
                    else if (index == 1 ){
                        passwordItem?.password = cell.txtValue!.text
                    }
                    else if (index == 2){
                        passwordItem?.link = cell.txtValue!.text
                    }
                    else if (index == 3) {
                        passwordItem?.note = cell.txtValue!.text
                    }
                }
                else {
                    var categorycell = self.tableView.cellForRowAtIndexPath(indexPath) as! CategoryCell
                    passwordItem?.category = categorycell.categoryButton!.titleLabel?.text
                }
            }
        }
        else{
            bDelete = true;
        }
        self.performSegueWithIdentifier("returnToPasswordList", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (bNewPassword){
            return 6
        }
        else{
            return 5
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var editcell : EditItemCell!
        // var notecell : EditNoteCell!
        editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as? EditItemCell
        
        if (editcell == nil){
            editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as! EditItemCell
        }
        
        if ( bNewPassword && indexPath.row == 0){
            editcell.labelName?.text = "ID (required)"
            editcell.txtValue?.text = passwordItem?.id
        }
        else if ( (bNewPassword && indexPath.row == 1) || (!bNewPassword && indexPath.row == 0)) {
            editcell.labelName?.text = "UserID"
            editcell.txtValue?.text = passwordItem?.userName
        }
        else if ( (bNewPassword && indexPath.row == 2) || (!bNewPassword && indexPath.row == 1)) {
            editcell.labelName?.text = "Password"
            editcell.txtValue?.text = passwordItem?.password
        }
        else if ( (bNewPassword && indexPath.row == 3) || (!bNewPassword && indexPath.row == 2)) {
            editcell.labelName?.text = "URL"
            editcell.txtValue?.text = passwordItem?.link
            editcell.txtValue?.placeholder = "https://"
        }
        else if ( (bNewPassword && indexPath.row == 4) || (!bNewPassword && indexPath.row == 3)){
            editcell.labelName?.text = "Notes"
            editcell.txtValue?.text = passwordItem?.note
        } else {
            var categorycell : CategoryCell!
            categorycell = tableView.dequeueReusableCellWithIdentifier("categoryitem") as? CategoryCell
            
            categorycell.categoryButton.setTitle(passwordItem?.category, forState: .Normal)
            if (passwordItem?.category == "Personal"){
                categorycell.categoryImage?.image = imageForPersonal
            }
            else if (passwordItem?.category == "Financial"){
                categorycell.categoryImage?.image = imageForFinancial
            }
            else if (passwordItem?.category == "Work"){
                categorycell.categoryImage?.image = imageForWork
            }
                /* else if (passwordItem?.category == "School"){
                categorycell.categoryImage?.image = imageForSchool
                }*/
            else{
                categorycell.categoryImage?.image = imageForOther
            }
            return categorycell
        }
        return editcell
    }
    
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println(indexPath);
    }
    // MARK: - Navigation
    /*  //this method is called when closing the detail screen and returning to parent screen.
    //it is used to handle password item update only. As new password is handled in onSave method
    override func didMoveToParentViewController(parent: UIViewController?){
    if (parent == nil && !bCancelled && !bNewPassword && !bDelete){
    // parent is nil if this view controller was removed
    // update password item
    for (var index = 0; index < 5; index++) {
    var indexPath = NSIndexPath(forRow: index, inSection: 0 )
    if ( index < 4){
    var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EditItemCell
    if (index == 0){
    passwordItem?.userName = cell.txtValue!.text
    }
    else if (index == 1 ){
    passwordItem?.password = cell.txtValue!.text
    }
    else if (index == 2){
    passwordItem?.link = cell.txtValue!.text
    }
    else if (index == 3) {
    passwordItem?.note = cell.txtValue!.text
    }
    }
    else {
    var categorycell = self.tableView.cellForRowAtIndexPath(indexPath) as! CategoryCell
    passwordItem?.category = categorycell.categoryButton!.titleLabel?.text
    }
    }
    (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.savePasswordFile()
    }
    }
    */
    //methods to handle new password
    func cancel(sender: UIBarButtonItem) {
        println("cancel clicked")
        self.bCancelled = true
        self.performSegueWithIdentifier("returnToPasswordList", sender: self)
        
    }
    
    func save(sender: UIBarButtonItem) {
        println("PasswordDetailsViewController save")
        var cell : EditItemCell?
        var categorycell : CategoryCell?
        
        for (var index = 0; index < 5; index++) {
            var indexPath = NSIndexPath(forRow: index, inSection: 0 )
            
            if ( index <= 4){
                cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EditItemCell
            }
            else{
                categorycell = self.tableView.cellForRowAtIndexPath(indexPath) as? CategoryCell
            }
            
            if (index == 0){
                
                let itemid = cell!.txtValue!.text
                
                if (itemid == ""){
                    
                    self.showAlert("Warning", message: "Password ID cannot be empty, please set a valid ID.", buttonTitle: "OK", handler: nil)
                    return
                }
                else {
                    //validate password id to be unique
                    let list =  (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.getPasswordItemList(nil)!
                    for p in list {
                        
                        if p.id == itemid {
                            self.showAlert("Warning", message: "Password ID '"+"'" + cell!.txtValue!.text + "' already exist, please set a different ID.", buttonTitle: "OK", handler: nil)
                            return
                        }
                    }
                }
                
                passwordItem?.id = cell!.txtValue!.text
            }
            else if (index == 1){
                passwordItem?.userName = cell!.txtValue!.text
            }
            else if (index == 2 ){
                passwordItem?.password = cell!.txtValue!.text
            }
            else if (index == 3){
                passwordItem?.link = cell!.txtValue!.text
            }
            else if (index == 4){
                passwordItem?.note = cell!.txtValue!.text
            }
            else if (index == 5){
                passwordItem?.category = categorycell!.categoryButton.titleLabel?.text
            }
        }
        
        
        self.performSegueWithIdentifier("returnToPasswordList", sender: self)
    }
    
    @IBAction func onPasswordItemEditChanged(sender: AnyObject) {
        //in update password mode, if user makes any change, then change the top menu from back to cancel, delete to save
        self.navigationItem.leftBarButtonItem?.title = "Cancel"
        self.navigationItem.rightBarButtonItem?.title = "Save"
    }
    
    
    @IBAction func onClickCategory(sender: AnyObject) {
        var rowId = 4;
        if (bNewPassword ){
            rowId = 5
        }
        let rows = [NSIndexPath(forRow: rowId, inSection: 0)]
        
        //show actionsheet to let user select the category
        let alertController = UIAlertController(title: "Category", message: "Select the category for the password item", preferredStyle: .Alert)
        
        let personalAction = UIAlertAction(title: "Personal", style: .Default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category="Personal"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(personalAction)
        
        let workAction = UIAlertAction(title: "Work", style: .Default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category="Work"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(workAction)
        
        let financialAction = UIAlertAction(title: "Financial", style: .Default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category = "Financial"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(financialAction)
        
        /*  let schoolAction = UIAlertAction(title: "School", style: .Default) { (action) in
        self.passwordItem?.category="School"
        self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(schoolAction)
        */
        let otherAction = UIAlertAction(title: "Others", style: .Default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category = "Others"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(otherAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
}
