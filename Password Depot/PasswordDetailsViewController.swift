//
//  PasswordDetailsViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/15/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit

class PasswordDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var passwordItem : PasswordItem?
    var bDelete: Bool = false
    var bNewPassword: Bool = false
    var bCancelled = false
    let imageForFinancial = UIImage(named: "financial")
    let imageForPersonal = UIImage(named:"personal")
    let imageForGeneral = UIImage(named:"general")

    func setPasswordItem(item:PasswordItem){
        self.passwordItem = item ;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if passwordItem is null, then it is for adding new password, otherwise it is for updating existing item
        if ( bNewPassword == true){
            self.navigationItem.title = "New Password"

            var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:"cancel:");
            self.navigationItem.rightBarButtonItem = rightButton
            
            var leftButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action:"save:");
            self.navigationItem.leftBarButtonItem = leftButton
            passwordItem = PasswordItem(id: "", userName: "", password: "", link: "", note: "")

        }
        else{
            self.title = passwordItem?.id
            // Do any additional setup after loading the view.
            
            var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action:"deleteItem:");
            self.navigationItem.rightBarButtonItem = rightButton
        }
        
        
    }
    
    func deleteItem(sender: UIBarButtonItem) {
        bDelete = true;
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
            editcell.labelName?.text = "ID"
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
            editcell.labelName?.text = "Link"
            editcell.txtValue?.text = passwordItem?.link
        }
        else if ( (bNewPassword && indexPath.row == 4) || (!bNewPassword && indexPath.row == 3)){
            editcell.labelName?.text = "Note"
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
            else{
                categorycell.categoryImage?.image = imageForGeneral
            }
            return categorycell
        }
        return editcell
    }
    
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        println(indexPath);
}
    // MARK: - Navigation
    
    override func didMoveToParentViewController(parent: UIViewController?){
        if (parent == nil){
            // parent is nil if this view controller was removed
            // update password item

            
                for (var index = 0; index < 4; index++) {
                    var indexPath = NSIndexPath(forRow: index, inSection: 0 )
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
                    else{
                        passwordItem?.note = cell.txtValue!.text
                    }
                }
            }
    }
    
    //methods to handle new password
   func cancel(sender: UIBarButtonItem) {
        println("cancel clicked")
        self.bCancelled = true
        self.performSegueWithIdentifier("returnToPasswordList", sender: self)

     }
    
     func save(sender: UIBarButtonItem) {
        println("save clicked")
                for (var index = 0; index < 5; index++) {
                    var indexPath = NSIndexPath(forRow: index, inSection: 0 )
                    var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EditItemCell
                    
                    if (index == 0){
                        passwordItem?.id = cell.txtValue!.text
                    }
                    else if (index == 1){
                        passwordItem?.userName = cell.txtValue!.text
                    }
                    else if (index == 2 ){
                        passwordItem?.password = cell.txtValue!.text
                    }
                    else if (index == 3){
                        passwordItem?.link = cell.txtValue!.text
                    }
                    else{
                        passwordItem?.note = cell.txtValue!.text
                    }
                }


        self.performSegueWithIdentifier("returnToPasswordList", sender: self)
     }

    @IBAction func onClickCategory(sender: AnyObject) {
        var rowId = 4;
        if (bNewPassword ){
            rowId = 5
        }
        let rows = [NSIndexPath(forRow: rowId, inSection: 0)]
        
        //show actionsheet to let user select the category
        let alertController = UIAlertController(title: "Category", message: "Select the category for the password item", preferredStyle: .Alert)

        let generalAction = UIAlertAction(title: "General", style: .Default) { (action) in
            self.passwordItem?.category = "General"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(generalAction)

        let financialAction = UIAlertAction(title: "Financial", style: .Default) { (action) in
            self.passwordItem?.category = "Financial"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(financialAction)
        
        let personalAction = UIAlertAction(title: "Personal", style: .Default) { (action) in
            self.passwordItem?.category="Personal"
            self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)

        }
        alertController.addAction(personalAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
    


        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
}
