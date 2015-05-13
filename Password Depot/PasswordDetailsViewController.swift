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
    
    func setPasswordItem(item:PasswordItem){
        self.passwordItem = item ;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    self.tableView.registerClass(EditItemCell.self, forCellReuseIdentifier: "edititem");
    //    self.tableView.registerClass(EditItemCell.self, forCellReuseIdentifier: "noteitem");

        self.title = passwordItem?.id
        // Do any additional setup after loading the view.
        
        var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action:"deleteItem:");
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func deleteItem(sender: UIBarButtonItem) {
        bDelete = true;
        self.performSegueWithIdentifier("deletePasswordItem", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
            return 4
    }
 
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var editcell : EditItemCell!
        var notecell : EditNoteCell!
            editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as? EditItemCell
            if (editcell == nil){
                editcell = tableView.dequeueReusableCellWithIdentifier("edititem") as! EditItemCell
            }
            if (indexPath.row == 0){
                editcell.labelName?.text = "UserID"
                editcell.txtValue?.text = passwordItem?.userName
            }
            else if (indexPath.row == 1){
                editcell.labelName?.text = "Password"
                editcell.txtValue?.text = passwordItem?.password
            }
            else if (indexPath.row == 2){
                editcell.labelName?.text = "Link"
                editcell.txtValue?.text = passwordItem?.link
            }
            else {
                editcell.labelName?.text = "Note"
                editcell.txtValue?.text = passwordItem?.note
            }
            return editcell
        }
    
            
    //    let imageForFinancial = UIImage(named: "star")
    //    let imageForOther = UIImage(named:"star2")
    //           cell!.imageView?.image = imageForFinancial;

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var passwordDetailViewController : PasswordDetailsViewController = segue.sourceViewController as! PasswordDetailsViewController
        
          }
    
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

}
