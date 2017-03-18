//
//  PasswordDetailsViewController.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/15/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//
import GoogleMobileAds
import UIKit


class PasswordDetailsViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
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
    
    func setPasswordItem(_ item:PasswordItem){
        self.passwordItem = item ;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func showAlert(_ title: String, message: String, buttonTitle: String, handler:((UIAlertAction?) -> Void )!){
        //first show the warning message and then show the createpasscodealert againg
        let alertDlg : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction : UIAlertAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler:handler);
        
        alertDlg.addAction(okAction)
        self.present(alertDlg, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-4348078921501765/4004108337"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PasswordDetailsViewController.cancel(_:)),
            name: NSNotification.Name(rawValue: "passwordFileUnloaded"),
            object: nil)
        
        //if passwordItem is null, then it is for adding new password, otherwise it is for updating existing item
        if ( bNewPassword == true){
            self.navigationItem.title = NSLocalizedString("New Password", comment: "")
            
            let leftButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action:#selector(PasswordDetailsViewController.cancel(_:)));
            leftButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = leftButton
            
            let rightButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action:#selector(PasswordDetailsViewController.save(_:)));
            rightButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = rightButton
            if (defaultCategoryForNewPassword == nil){
                defaultCategoryForNewPassword = "Personal"
            }
            passwordItem = PasswordItem(id: "", userName: "", password: "", link: "https://", note: "", category:defaultCategoryForNewPassword!)
            
        }
        else{
            self.title = passwordItem?.id
            // Do any additional setup after loading the view.
            let leftButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action:#selector(PasswordDetailsViewController.cancel(_:)));
            leftButton.tintColor = UIColor.white

            self.navigationItem.leftBarButtonItem = leftButton
            
            let rightButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Delete", comment:""), style: UIBarButtonItemStyle.plain, target: self, action:#selector(PasswordDetailsViewController.deleteItem(_:)));
            rightButton.tintColor = UIColor.white

            self.navigationItem.rightBarButtonItem = rightButton
        }
        
        
    }
    
    func deleteItem(_ sender: UIBarButtonItem) {
        if (self.navigationItem.rightBarButtonItem?.title == NSLocalizedString("Save", comment: "")){
            bUpdate = true;
            for index in 0 ..< 5 {
                let indexPath = IndexPath(row: index, section: 0 )
                if ( index < 3){
                    let cell = self.tableView.cellForRow(at: indexPath) as! EditItemCell
                    if (index == 0){
                        passwordItem?.userName = cell.txtValue!.text!
                    }
                    else if (index == 1 ){
                        passwordItem?.password = cell.txtValue!.text!
                    }
                    else if (index == 2){
                        passwordItem?.link = cell.txtValue!.text
                    }
                 }
                 else if (index == 3) {
                     let note = self.tableView.cellForRow(at: indexPath) as! EditNoteCell
                       passwordItem?.note = note.noteValue!.text
                  }
                  else {
                    let categorycell = self.tableView.cellForRow(at: indexPath) as! CategoryCell
                    passwordItem?.category = categorycell.categoryButton!.titleLabel?.text
                }
            }
        }
        else{
            bDelete = true;
        }
        self.performSegue(withIdentifier: "returnToPasswordList", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (bNewPassword){
            return 6
        }
        else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var editcell : EditItemCell!
        var notecell : EditNoteCell!
        editcell = tableView.dequeueReusableCell(withIdentifier: "edititem") as? EditItemCell
        
        if (editcell == nil){
            editcell = tableView.dequeueReusableCell(withIdentifier: "edititem") as! EditItemCell
        }
        
        if ( bNewPassword && (indexPath as NSIndexPath).row == 0){
            editcell.labelName?.text = NSLocalizedString("ID (required)", comment:"")
            editcell.txtValue?.text = passwordItem?.id
        }
        else if ( (bNewPassword && (indexPath as NSIndexPath).row == 1) || (!bNewPassword && (indexPath as NSIndexPath).row == 0)) {
            editcell.labelName?.text = NSLocalizedString("UserID", comment:"")
            editcell.txtValue?.text = passwordItem?.userName
        }
        else if ( (bNewPassword && (indexPath as NSIndexPath).row == 2) || (!bNewPassword && (indexPath as NSIndexPath).row == 1)) {
            editcell.labelName?.text = NSLocalizedString("Password", comment:"")
            editcell.txtValue?.text = passwordItem?.password
        }
        else if ( (bNewPassword && (indexPath as NSIndexPath).row == 3) || (!bNewPassword && (indexPath as NSIndexPath).row == 2)) {
            editcell.labelName?.text = NSLocalizedString("URL", comment: "")
            editcell.txtValue?.text = passwordItem?.link
            editcell.txtValue?.placeholder = "https://"
        }
        else if ( (bNewPassword && (indexPath as NSIndexPath).row == 4) || (!bNewPassword && (indexPath as NSIndexPath).row == 3)){
            notecell = tableView.dequeueReusableCell(withIdentifier: "noteitem") as? EditNoteCell
            notecell.noteValue.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
            notecell.noteValue.layer.borderWidth = 1.0;

            notecell.noteName?.text = NSLocalizedString("Notes", comment:"")
            notecell.noteValue?.text = passwordItem?.note
            return notecell;
        } else {
            var categorycell : CategoryCell!
            categorycell = tableView.dequeueReusableCell(withIdentifier: "categoryitem") as? CategoryCell
            
            categorycell.categoryButton.setTitle(getLocalizedCategoryName(category: passwordItem?.category), for: UIControlState())
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
    
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print(indexPath);
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
    func cancel(_ sender: UIBarButtonItem) {
        print("cancel clicked")
        self.bCancelled = true
        self.performSegue(withIdentifier: "returnToPasswordList", sender: self)
        
    }
    
    func save(_ sender: UIBarButtonItem) {
        print("PasswordDetailsViewController save")
        var cell : EditItemCell?
        var notecell : EditNoteCell?
        var categorycell : CategoryCell?
        
        for index in 0 ..< 5 {
            let indexPath = IndexPath(row: index, section: 0 )
            
            if ( index < 4){
                cell = self.tableView.cellForRow(at: indexPath) as? EditItemCell
            }
            else if (index == 4){
                notecell = self.tableView.cellForRow(at: indexPath) as? EditNoteCell
            }
            else{
                categorycell = self.tableView.cellForRow(at: indexPath) as? CategoryCell
            }
            
            if (index == 0){
                
                let itemid = cell!.txtValue!.text
                
                if (itemid == ""){
                    
                    self.showAlert(NSLocalizedString("Warning", comment:""), message: NSLocalizedString("Password ID cannot be empty, please set a valid ID.", comment:""), buttonTitle: NSLocalizedString("OK", comment:""), handler: nil)
                    return
                }
                else {
                    //validate password id to be unique
                    let list =  (UIApplication.shared.delegate as! AppDelegate).passwordManager.getPasswordItemList(nil, nil)!
                    for p in list {
                        
                        if p.id == itemid {
                            self.showAlert(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Password ID '", comment:"") + "'" + cell!.txtValue!.text! + NSLocalizedString("' already exist, please set a different ID.", comment:""), buttonTitle: NSLocalizedString("OK", comment:""), handler: nil)
                            return
                        }
                    }
                }
                
                passwordItem?.id = cell!.txtValue!.text!
            }
            else if (index == 1){
                passwordItem?.userName = cell!.txtValue!.text!
            }
            else if (index == 2 ){
                passwordItem?.password = cell!.txtValue!.text!
            }
            else if (index == 3){
                passwordItem?.link = cell!.txtValue!.text
            }
            else if (index == 4){
                passwordItem?.note = notecell!.noteValue!.text
            }
            else if (index == 5){
                passwordItem?.category = categorycell!.categoryButton.titleLabel?.text
            }
        }
        
        
        self.performSegue(withIdentifier: "returnToPasswordList", sender: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onPasswordItemEditChanged(self);
    }
    
    @IBAction func onPasswordItemEditChanged(_ sender: AnyObject) {
        //in update password mode, if user makes any change, then change the top menu from back to cancel, delete to save
        self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("Cancel", comment:"")
        self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Save",comment:"")
    }
    
    
    @IBAction func onClickCategory(_ sender: AnyObject) {
        var rowId = 4;
        if (bNewPassword ){
            rowId = 5
        }
        let rows = [IndexPath(row: rowId, section: 0)]
        
        //show actionsheet to let user select the category
        let alertController = UIAlertController(title: NSLocalizedString("Category", comment:""), message: NSLocalizedString("Select the category for the password item", comment:""), preferredStyle: .alert)
        
        let personalAction = UIAlertAction(title: NSLocalizedString("Personal", comment:""), style: .default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category="Personal"
            self.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.none)
        }
        alertController.addAction(personalAction)
        
        let workAction = UIAlertAction(title: NSLocalizedString("Work", comment:""), style: .default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category="Work"
            self.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.none)
        }
        alertController.addAction(workAction)
        
        let financialAction = UIAlertAction(title: NSLocalizedString("Financial", comment:""), style: .default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category = "Financial"
            self.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.none)
        }
        alertController.addAction(financialAction)
        
        /*  let schoolAction = UIAlertAction(title: "School", style: .Default) { (action) in
        self.passwordItem?.category="School"
        self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
        }
        alertController.addAction(schoolAction)
        */
        let otherAction = UIAlertAction(title: NSLocalizedString("Others", comment:""), style: .default) { (action) in
            self.onPasswordItemEditChanged(action);
            self.passwordItem?.category = "Others"
            self.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.none)
        }
        alertController.addAction(otherAction)
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    private func getLocalizedCategoryName(category: String?) -> String{
        var result :String? = nil
        let categoryName = category ?? "Personal"
        
        switch categoryName {
            case "Work":
                result = NSLocalizedString("Work", comment:"")
                break
            case "Financial":
                result = NSLocalizedString("Financial", comment:"")
                break
            case "Others":
                result = NSLocalizedString("Others", comment:"")
                break
            default:
                result = NSLocalizedString("Personal", comment: "")
        }
        return result!
    }
    
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowNote") {
            let destinationController : NoteEditViewController = segue.destination as! NoteEditViewController;
            let noteCell = sender as! EditNoteCell;
            destinationController.noteData = noteCell.noteValue.text;
            destinationController.noteCell = noteCell;
            destinationController.parentVC = self;
        }
     }

}
