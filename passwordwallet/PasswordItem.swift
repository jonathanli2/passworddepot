//
//  PasswordItem.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/18/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import Foundation

class PasswordItem {
    var userName : String
    var password : String
    var id : String
    var link : String? = nil
    var note : String? = nil
    var category : String? = "Personal"
    
    func toDictionary () -> NSDictionary{
        let dic : NSMutableDictionary = ["id":self.id, "userName":self.userName, "password":self.password]
        if ((self.link) != nil) {
            dic.setValue(self.link, forKey: "url")
        }
        
        if ((self.note) != nil) {
            dic.setValue(self.note, forKey: "note")
        }
        
        if ((self.category) != nil) {
            dic.setValue(self.category, forKey: "category")
        }
        return dic;
    }
    
    init(id:String, userName:String, password:String, link:String, note:String, category:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = link
        self.note = note
        self.category = category
    }
    

      init(id:String, userName:String, password:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = nil
    }
}

class PasswordManager{
     private var passwordList : [PasswordItem]?
    
     //if encrytionKey is nil, it means password file is locked
     private var encryptionKey : NSData?
     //un order to support touch id, the last used encryption key is saved in memory, and it is not unloaded when
     //encryption key is unloaded. Once the touch id is authenticated, then set lastUsedEncrytionKey to cryptionKey and continue.
     //in any operation than may change the password, the lastUsedEncrytionKey should be reset
     //if lastUsedEncrytionKey is null, then do not enable touch id login
     private var lastUsedEncrytionKey : NSData?
    
    
     private func getMatchedItemByCategory( categoryFilter : String) -> [PasswordItem] {
        var filteredPasswordList = [PasswordItem]()
        for item in self.passwordList! {
            if ( item.category == categoryFilter ){
                filteredPasswordList.append(item)
            }
        }
        
        return filteredPasswordList
     }
    
     //return nil if list does not exist.
     func getPasswordItemList(categoryFilter: String?) -> [PasswordItem]? {
        if let list = passwordList {
            if ( categoryFilter == nil || categoryFilter == ""){
                return list
            }
            else{ //apply filter
                return getMatchedItemByCategory(categoryFilter!)
            }
        }
        else{
            return nil;
        }
     }
    
    
    func getPasswordFileContent()->NSData {
            //load data from file
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (paths as NSString).stringByAppendingPathComponent("passwords.dat")
        let data = NSData(contentsOfFile: path)
        return data!
   
    }
    
    func addPasswordItem(item: PasswordItem) -> [PasswordItem]{
        passwordList?.append(item)
        savePasswordFile()
        return passwordList!
    }
    
    //search all category items based on ID
    func getPasswordItemByID(passwordID : String) -> PasswordItem?{
        //validate password id to be unique
        var selectedItem : PasswordItem? = nil;
        
        if (self.passwordList != nil) {
            for p in self.passwordList! {
            
                if p.id == passwordID {
                    selectedItem = p
                    break
                }
            }
        }
        return selectedItem

    }
    
    
    func deletePasswordItem(item : PasswordItem){
    
        for (var index = 0; index < self.passwordList!.count; index++) {
            if ( item.id == self.passwordList![index].id){
                self.passwordList?.removeAtIndex(index);
                break;
            }
        }
        
    }
    
    func isPasswordFileExisting() -> Bool{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (paths as NSString).stringByAppendingPathComponent("passwords.dat")
        let checkValidation = NSFileManager.defaultManager()

        if (checkValidation.fileExistsAtPath(path)){
            return true
        }
        else{
            return false
        }
    }

    
    func isPasswordFileUnlocked() -> Bool{
        if (self.encryptionKey == nil){
            return false
        }
        else{
            return true
        }
    }

    
    func copyPasswordFile(sourcePath : String, err: NSErrorPointer){
        var error : NSError?
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (paths as NSString).stringByAppendingPathComponent("passwords.dat")
        if (isPasswordFileExisting()){
            do {
                try fileManager.removeItemAtPath(path)
            } catch let error1 as NSError {
                error = error1
            }
        }
        if let e = error {
            err.memory = e
        }
        else{
            do {
                //copy the file
                try fileManager.moveItemAtPath(sourcePath, toPath: path)
            } catch let error1 as NSError {
                error = error1
            }
            do {
                try fileManager.removeItemAtPath(sourcePath)
            } catch _ {
            }
      
            if let e = error {
                err.memory = e
               
            }
            else{
                self.encryptionKey = nil
                self.lastUsedEncrytionKey = nil
                NSNotificationCenter.defaultCenter().postNotificationName("passwordFileChanged", object: nil)
            }
        }

    }

    private func convertToPasswordItemArray( passwords : NSMutableArray){
        var arr :[PasswordItem]? = [];
        for (var index : Int = 0; index < passwords.count; index++){
            let dic = passwords[index] as! NSDictionary
            let pass = PasswordItem(id: dic.valueForKey("id") as! String, userName: dic.valueForKey("userName") as! String, password: dic.valueForKey("password") as! String)
            
            pass.link = dic.valueForKey("url") as? String
            pass.note = dic.valueForKey("note") as? String
            pass.category = dic.valueForKey("category") as? String
            arr!.append(pass)
        }
        self.passwordList = arr as [PasswordItem]?
    }
    
    func hasLastUsedEncrytionKey() -> Bool {
        if (self.lastUsedEncrytionKey == nil ){
            return false;
        }
        else{
            return true;
        }
    }
    
    func loadPasswordFileWithLastUsedEncryptionKey() -> Bool {
         if let savedKey = self.lastUsedEncrytionKey {
             encryptionKey = savedKey;
             return loadPasswordFileWithEncryptionKey();
         }
         return false;
    }
    
    func loadPasswordFile(passcode : String) -> Bool{
           
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        return loadPasswordFileWithEncryptionKey();
     }
    
    private func loadPasswordFileWithEncryptionKey() -> Bool{
           //load data from file
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (paths as NSString).stringByAppendingPathComponent("passwords.dat")
        let data = NSData(contentsOfFile: path)
        
        let decryptedData = decryptData(data!, key: encryptionKey!);
        let list: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(decryptedData!, options: NSJSONReadingOptions.MutableContainers)
        if let passwords: AnyObject = list {
            convertToPasswordItemArray(passwords as! NSMutableArray)
            self.lastUsedEncrytionKey = encryptionKey;
            return true
        }
        else{
            encryptionKey = nil;
            return false
        }
    }
    
    private func convertToDictionaryArray() ->  NSMutableArray {
        let arr : NSMutableArray = [];
        for (var index : Int = 0; index < passwordList?.count; index++){
            let pass = self.passwordList![index]
            let dic = pass.toDictionary()
            arr.addObject(dic)
        }
        return arr;
    }
    
    func unloadPasswordFile() {
        print("PasswordItems UnloadPasswordFile")
        encryptionKey = nil
        passwordList = nil
    }
    
    func setBackgroundTimeout(timeout : Int){
    }
    
    func savePasswordFile(){
        print("PasswordItem savePasswordFile");

        let dicArray = convertToDictionaryArray();
        let data : NSData? = try? NSJSONSerialization.dataWithJSONObject(dicArray, options: NSJSONWritingOptions.PrettyPrinted)
      
        let encryptedData = encryptData(data!, key: encryptionKey!);
        //save file
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (paths as NSString).stringByAppendingPathComponent("passwords.dat")
        do {
            try encryptedData?.writeToFile(path, options:NSDataWritingOptions.DataWritingFileProtectionComplete)
        } catch _ {
        }
     
    }
    
    func createPasswordFile(passcode: String){
        passwordList = [];
        
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        self.lastUsedEncrytionKey  = encryptionKey;
        savePasswordFile()
        
    }

    func changePassword(passcode: String){
        print("PasswordItem changePassword");
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        lastUsedEncrytionKey = encryptionKey;
        savePasswordFile()
    }

    
    func getKeyFromPassword(password : String, salt:NSData) -> NSData{
        let derivedKey = NSMutableData(length: kCCKeySizeAES128);
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), NSString(string: password).UTF8String,
            password.characters.count, UnsafePointer<UInt8>(salt.bytes), salt.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
            uint(100),
            UnsafeMutablePointer<UInt8>(derivedKey!.mutableBytes),
            derivedKey!.length)
      
        return derivedKey!;
    }
    
    func encryptData(data : NSData, key:NSData) -> NSData?{
        var outLength : size_t = 0;
        let cipherData : NSMutableData? = NSMutableData(length: data.length + kCCBlockSizeAES128);
        let result = CCCrypt(            UInt32(kCCEncrypt), // operation
                                         UInt32(kCCAlgorithmAES128), // algorithm
                                         UInt32(kCCOptionPKCS7Padding), // options
                                         UnsafePointer<UInt8>(key.bytes), // key
                                         key.length, // keylength
                                         nil, // iv
                                         UnsafePointer<UInt8>(data.bytes), // dataIn
                                         data.length, // dataInLength,
                                         UnsafeMutablePointer<UInt8>(cipherData!.mutableBytes), // dataOut
                                         cipherData!.length, // dataOutAvailable
                                         &outLength); // dataOutMoved
        
        if (UInt32(result) == UInt32(kCCSuccess)) {
            cipherData!.length = outLength;
            return cipherData
        }
        else {
            return nil;
        }
    }
    
    func decryptData(data:NSData, key:NSData ) -> NSData? {
        var  outLength : size_t = 0;
        
        let decryptedData : NSMutableData? = NSMutableData(length: data.length);
        let result = CCCrypt(UInt32(kCCDecrypt), // operation
                                         UInt32(kCCAlgorithmAES128), // algorithm
                                         UInt32(kCCOptionPKCS7Padding), // options
                                         UnsafePointer<UInt8>(key.bytes), // key
                                         key.length, // keylength
                                         nil, // iv
                                         UnsafePointer<UInt8>(data.bytes), // dataIn
                                         data.length, // dataInLength,
                                         UnsafeMutablePointer<UInt8>(decryptedData!.mutableBytes), // dataOut
                                         decryptedData!.length, // dataOutAvailable
                                         &outLength); // dataOutMoved
        
        if (UInt(result) == UInt(kCCSuccess)) {
            decryptedData!.length = outLength;
            return decryptedData;
        }
        else {
            return nil;
        }
        

    }


}
