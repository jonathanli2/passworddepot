//
//  CreatePasswordViewController.swift
//  Password Depot
//
//  Created by Li, Jonathan on 4/22/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import UIKit

class CreatePasswordViewController: UIViewController {

    var newPassword : PasswordItem?
    
    @IBOutlet weak var id: UITextField!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var btnExit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Password"
 //       self.title = passwordItem?.id
        // Do any additional setup after loading the view.
        
        var rightButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:"cancel:");
        self.navigationItem.rightBarButtonItem = rightButton
        
       var leftButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action:"save:");
        self.navigationItem.leftBarButtonItem = leftButton
     }

     func cancel(sender: UIBarButtonItem) {
        println("cancel clicked")
        self.newPassword = nil
        btnExit.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
     }
    
     func save(sender: UIBarButtonItem) {
        println("save clicked")
        self.newPassword = PasswordItem(id: id.text, userName: userName.text, password: password.text)
        btnExit.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
     }
    
       override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
              println("from segue id: %@", segue.identifier);
    }

}
