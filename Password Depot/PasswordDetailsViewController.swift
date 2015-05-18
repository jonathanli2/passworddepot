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
            return 5
        }
        else{
            return 4
        }
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var editcell : EditItemCell!
        var notecell : EditNoteCell!
        editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as? EditItemCell
        var indexDiff = 0
        if bNewPassword {
            indexDiff = 1
        }
        else{
            indexDiff = 0
        }
        
        if (editcell == nil){
            editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as! EditItemCell
        }
        
        if ( indexDiff > 0 && indexPath.row == -1 + indexDiff){
            editcell.labelName?.text = "ID"
            editcell.txtValue?.text = passwordItem?.id
        }
        else if (indexPath.row == 0 + indexDiff){
            editcell.labelName?.text = "UserID"
            editcell.txtValue?.text = passwordItem?.userName
        }
        else if (indexPath.row == 1 + indexDiff){
            editcell.labelName?.text = "Password"
            editcell.txtValue?.text = passwordItem?.password
        }
        else if (indexPath.row == 2 + indexDiff){
            editcell.labelName?.text = "Link"
            editcell.txtValue?.text = passwordItem?.link
        }
        else {
            editcell.labelName?.text = "Note"
            editcell.txtValue?.text = passwordItem?.note
        }
        return editcell
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

}
