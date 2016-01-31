//
//  NoteEditViewController.swift
//  passwordwallet
//
//  Created by Li, Jonathan on 1/28/16.
//  Copyright © 2016 Mobi Solution. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController {

    @IBOutlet weak var NoteText: UITextView!
    var noteData : String?
    var noteCell : EditNoteCell!
    var parentVC : PasswordDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.canDisplayBannerAds = true
        self.NoteText.text = noteData;
       self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
 
    }
    
   override func willMoveToParentViewController(parent: UIViewController?) {
        if (parent == nil){
        
           if ( noteCell.noteValue.text != self.NoteText.text){
             noteCell.noteValue.text = self.NoteText.text;
             parentVC.onPasswordItemEditChanged(self);
            }
        }
    }
}
