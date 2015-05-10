//
//  PasswordDetailsViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/15/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit

class PasswordDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var passwordItem : PasswordItem?
    
    func setPasswordItem(item:PasswordItem){
        self.passwordItem = item ;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = passwordItem?.id
        // Do any additional setup after loading the view.
        
        var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action:"edit:");
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func edit(sender: UIBarButtonItem) {
        println("start edit")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
 
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("detail") as? UITableViewCell
        
        if (cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "detail")
        }
        
    //    let imageForFinancial = UIImage(named: "star")
    //    let imageForOther = UIImage(named:"star2")
    //           cell!.imageView?.image = imageForFinancial;
        if (indexPath.row == 0){
            cell!.textLabel?.text = "Username"
            print(passwordItem?.userName)
            cell!.detailTextLabel?.text = passwordItem?.userName
        }
        else{
            cell!.textLabel?.text = "Password"
            print(passwordItem?.password)
            cell!.detailTextLabel?.text = passwordItem?.password
        }
    
      //  cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
