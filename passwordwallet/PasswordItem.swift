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
        var dic : NSMutableDictionary = ["id":self.id, "userName":self.userName, "password":self.password]
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
     private var encryptionKey : NSData?
    
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
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("passwords.dat")
        var data = NSData(contentsOfFile: path)
        return data!
   
    }
    
    func addPasswordItem(item: PasswordItem) -> [PasswordItem]{
        passwordList?.append(item)
        savePasswordFile()
        return passwordList!
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
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("passwords.dat")
        var checkValidation = NSFileManager.defaultManager()

        if (checkValidation.fileExistsAtPath(path)){
            return true
        }
        else{
            return false
        }
    }
    
    func copyPasswordFile(sourcePath : String, err: NSErrorPointer){
        var fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("passwords.dat")
        if (isPasswordFileExisting()){
            fileManager.removeItemAtPath(path, error:err)
        }
        
        //copy the file
        fileManager.moveItemAtPath(sourcePath, toPath: path, error: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("passwordFileChanged", object: nil)

    }

    private func convertToPasswordItemArray( passwords : NSMutableArray){
        var arr :[PasswordItem]? = [];
        for (var index : Int = 0; index < passwords.count; index++){
            var dic = passwords[index] as! NSDictionary
            var pass = PasswordItem(id: dic.valueForKey("id") as! String, userName: dic.valueForKey("userName") as! String, password: dic.valueForKey("password") as! String)
            
            pass.link = dic.valueForKey("url") as? String
            pass.note = dic.valueForKey("note") as? String
            pass.category = dic.valueForKey("category") as? String
            arr!.append(pass)
        }
        self.passwordList = arr as [PasswordItem]?
    }
    
    
    func loadPasswordFile(passcode : String) -> Bool{
           
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        
        //load data from file
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("passwords.dat")
        var data = NSData(contentsOfFile: path)
        
        let decryptedData = decryptData(data!, key: encryptionKey!);
        var list: AnyObject? = NSJSONSerialization.JSONObjectWithData(decryptedData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if let passwords: AnyObject = list {
            convertToPasswordItemArray(passwords as! NSMutableArray)
            return true
        }
        else{
            return false
        }
    }
    
    private func convertToDictionaryArray() ->  NSMutableArray {
        var arr : NSMutableArray = [];
        for (var index : Int = 0; index < passwordList?.count; index++){
            var pass = self.passwordList![index]
            var dic = pass.toDictionary()
            arr.addObject(dic)
        }
        return arr;
    }
    
    func unloadPasswordFile() {
        println("PasswordItems UnloadPasswordFile")
        encryptionKey = nil
        passwordList = nil
    }
    
    func setBackgroundTimeout(timeout : Int){
    }
    
    func savePasswordFile(){
        println("PasswordItem savePasswordFile");

        let dicArray = convertToDictionaryArray();
        let data : NSData? = NSJSONSerialization.dataWithJSONObject(dicArray, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
      
        let encryptedData = encryptData(data!, key: encryptionKey!);
        //save file
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("passwords.dat")
        encryptedData?.writeToFile(path, options:NSDataWritingOptions.DataWritingFileProtectionComplete, error: nil)
     
    }
    
    func createPasswordFile(passcode: String){
        passwordList = [];
        
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
      
        savePasswordFile()
        
    }

    func changePassword(passcode: String){
        println("PasswordItem changePassword");
        let saltStr : String = "salt"
        let salt = saltStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
      
        savePasswordFile()
    }

    
    func getKeyFromPassword(password : String, salt:NSData) -> NSData{
        var derivedKey = NSMutableData(length: kCCKeySizeAES128);
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), NSString(string: password).UTF8String,
            count(password), UnsafePointer<UInt8>(salt.bytes), salt.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
            uint(100),
            UnsafeMutablePointer<UInt8>(derivedKey!.mutableBytes),
            derivedKey!.length)
      
        return derivedKey!;
    }
    
    func encryptData(data : NSData, key:NSData) -> NSData?{
        var outLength : size_t = 0;
        var cipherData : NSMutableData? = NSMutableData(length: data.length + kCCBlockSizeAES128);
        var result = CCCrypt(            UInt32(kCCEncrypt), // operation
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
        
        var decryptedData : NSMutableData? = NSMutableData(length: data.length);
        var result = CCCrypt(UInt32(kCCDecrypt), // operation
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
