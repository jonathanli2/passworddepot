//
//  NoteEditViewController.swift
//  passwordwallet
//
//  Created by Li, Jonathan on 1/28/16.
//  Copyright © 2016 Mobi Solution. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NoteEditViewController: UIViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var NoteText: UITextView!
    var noteData : String?
    var noteCell : EditNoteCell!
    var parentVC : PasswordDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-4348078921501765/4004108337"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())


        self.NoteText.text = noteData;
       self.navigationController!.navigationBar.tintColor = UIColor.white
 
    }
    
   override func willMove(toParentViewController parent: UIViewController?) {
        if (parent == nil){
        
           if ( noteCell.noteValue.text != self.NoteText.text){
             noteCell.noteValue.text = self.NoteText.text;
             parentVC.onPasswordItemEditChanged(self);
            }
        }
    }
}
