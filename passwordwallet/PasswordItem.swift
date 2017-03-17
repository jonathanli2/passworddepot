//
//  PasswordItem.swift
//  SafeVault
//
//  Created by Li, Jonathan on 4/18/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PasswordItem {

    //public access scope
    public var userName : String
    public var password : String
    public var id : String
    public var link : String? = nil
    public var note : String? = nil
    public var category : String? = "Personal"
    
    public init(id:String, userName:String, password:String, link:String, note:String, category:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = link
        self.note = note
        self.category = category
    }
  
    //file private access scope
    fileprivate func toDictionary () -> NSDictionary{
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
    
    fileprivate init(id:String, userName:String, password:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = nil
    }
    

}

class PasswordManager{
     private var passwordList : [PasswordItem]?
    
     //if encrytionKey is nil, it means password file is locked
     private var encryptionKey : Data?
     //un order to support touch id, the last used encryption key is saved in memory, and it is not unloaded when
     //encryption key is unloaded. Once the touch id is authenticated, then set lastUsedEncrytionKey to cryptionKey and continue.
     //in any operation than may change the password, the lastUsedEncrytionKey should be reset
     //if lastUsedEncrytionKey is null, then do not enable touch id login
     private var lastUsedEncrytionKey : Data?
    
     //the below two variable is used for caching the filtered password item list, so there is no need to filter the whole password item 
     //each time if the filter criteria and password raw list is not changed
     private var lastFilterCategory : String?
     private var lastFilterString : String?
     private var cachedPasswordListBasedOnFilter : [PasswordItem]?
    
     private func getMatchedItemByCategory( _ categoryFilter : String) -> [PasswordItem] {
        var filteredPasswordList = [PasswordItem]()
        for item in self.passwordList! {
            if ( item.category == categoryFilter ){
                filteredPasswordList.append(item)
            }
        }
        
        return filteredPasswordList
     }
    
    private func filterItemsBySearchString( _ input :  [PasswordItem], _ stringFilter : String) -> [PasswordItem] {
        let filter = stringFilter.lowercased()
        var filterPasswordList = [PasswordItem]()
        for item in input {
            if ( item.id.lowercased().contains(filter) || (item.note?.lowercased().contains(filter))! || (item.link?.lowercased().contains(filter))!){
                filterPasswordList.append(item)
            }
        }
        
        return filterPasswordList
     }

    
     private func convertToPasswordItemArray( _ passwords : NSMutableArray){
        var arr :[PasswordItem]? = [];
        for index : Int in 0..<passwords.count{
            let dic = passwords[index] as! NSDictionary
            let pass = PasswordItem(id: dic.value(forKey: "id") as! String, userName: dic.value(forKey: "userName") as! String, password: dic.value(forKey: "password") as! String)
            
            pass.link = dic.value(forKey: "url") as? String
            pass.note = dic.value(forKey: "note") as? String
            pass.category = dic.value(forKey: "category") as? String
            arr!.append(pass)
        }
        self.passwordList = arr as [PasswordItem]?
    }
    
    private func loadPasswordFileWithEncryptionKey() -> Bool{
           //load data from file
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let path = (paths as NSString).appendingPathComponent("passwords.dat")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        
        let decryptedData = decryptData(data!, key: encryptionKey!);
        let list: AnyObject? = try! JSONSerialization.jsonObject(with: decryptedData!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
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
        for index in 0..<passwordList!.count {
            let pass = self.passwordList![index]
            let dic = pass.toDictionary()
            arr.add(dic)
        }
        return arr;
    }
    private func getKeyFromPassword(_ password : String, salt:Data) -> Data{
        let derivedKey = NSMutableData(length: kCCKeySizeAES128);
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), NSString(string: password).utf8String,
            password.characters.count, (salt as NSData).bytes.bindMemory(to: UInt8.self, capacity: salt.count), salt.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
            uint(100),
            UnsafeMutablePointer<UInt8>(derivedKey!.mutableBytes.assumingMemoryBound(to:UInt8.self)),
            derivedKey!.length)
      
        return derivedKey! as Data;
    }
    
    private func encryptData(_ data : Data, key:Data) -> Data?{
        var outLength : size_t = 0;
        let cipherData : NSMutableData? = NSMutableData(length: data.count + kCCBlockSizeAES128);
        let result = CCCrypt(            UInt32(kCCEncrypt), // operation
                                         UInt32(kCCAlgorithmAES128), // algorithm
                                         UInt32(kCCOptionPKCS7Padding), // options
                                         (key as NSData).bytes.bindMemory(to: UInt8.self, capacity: key.count), // key
                                         key.count, // keylength
                                         nil, // iv
                                         (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), // dataIn
                                         data.count, // dataInLength,
                                         UnsafeMutablePointer<UInt8>(cipherData!.mutableBytes.assumingMemoryBound(to:UInt8.self)), // dataOut
                                         cipherData!.length, // dataOutAvailable
                                         &outLength); // dataOutMoved
        
        if (UInt32(result) == UInt32(kCCSuccess)) {
            cipherData!.length = outLength;
            return cipherData as Data?
        }
        else {
            return nil;
        }
    }
    
    private func decryptData(_ data:Data, key:Data ) -> Data? {
        var  outLength : size_t = 0;
        
        let decryptedData : NSMutableData? = NSMutableData(length: data.count);
        let result = CCCrypt(UInt32(kCCDecrypt), // operation
                                         UInt32(kCCAlgorithmAES128), // algorithm
                                         UInt32(kCCOptionPKCS7Padding), // options
                                         (key as NSData).bytes.bindMemory(to: UInt8.self, capacity: key.count), // key
                                         key.count, // keylength
                                         nil, // iv
                                         (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), // dataIn
                                         data.count, // dataInLength,
                                         UnsafeMutablePointer<UInt8>(decryptedData!.mutableBytes.assumingMemoryBound(to:UInt8.self)), // dataOut
                                         decryptedData!.length, // dataOutAvailable
                                         &outLength); // dataOutMoved
        
        if (UInt(result) == UInt(kCCSuccess)) {
            decryptedData!.length = outLength;
            return decryptedData as Data?;
        }
        else {
            return nil;
        }
    }
    
    private func resetCachedFilterResult() {
        lastFilterCategory = nil
        lastFilterString = nil
        cachedPasswordListBasedOnFilter = nil
    }


    
     // MARK: public access scope function
    
     // MARK: public function will not change the password item list content
    
     //return nil if list does not exist.
     public func getPasswordItemList(_ categoryFilter: String?, _ stringFilter: String? ) -> [PasswordItem]? {
        var result : [PasswordItem]? = nil
        
        //check whether the search criteria is changed, if not, then return the cached value
        if (categoryFilter == lastFilterCategory && stringFilter == lastFilterString && cachedPasswordListBasedOnFilter != nil){
            result = cachedPasswordListBasedOnFilter;
        }
        else{
            if let list = passwordList {
                if ( categoryFilter == nil || categoryFilter == ""){
                    result = list
                }
                else{ //apply filter
                    result = getMatchedItemByCategory(categoryFilter!)
                }
                
                //apply string search filter
                if ( stringFilter != nil && stringFilter != ""){
                    result = filterItemsBySearchString(result!, stringFilter!)
                }
            }
            else{
                result = nil;
            }
            
            //sort result
            if (result != nil){
                result = result?.sorted(by: { (a, b) -> Bool in
                    b.id.lowercased() > a.id.lowercased()
                })
            }
            
            lastFilterCategory = categoryFilter;
            lastFilterString = stringFilter;
            cachedPasswordListBasedOnFilter = result;
        }
        
        return result
     }
    
    //search all category items based on ID
    public func getPasswordItemByID(_ passwordID : String) -> PasswordItem?{
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

    
    public func getPasswordFileContent()->Data {
            //load data from file
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let path = (paths as NSString).appendingPathComponent("passwords.dat")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data!
   
    }
    
    public func isPasswordFileExisting() -> Bool{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let path = (paths as NSString).appendingPathComponent("passwords.dat")
        let checkValidation = FileManager.default

        if (checkValidation.fileExists(atPath: path)){
            return true
        }
        else{
            return false
        }
    }
    
    public func isPasswordFileUnlocked() -> Bool{
        if (self.encryptionKey == nil){
            return false
        }
        else{
            return true
        }
    }
    
    public func hasLastUsedEncrytionKey() -> Bool {
        if (self.lastUsedEncrytionKey == nil ){
            return false;
        }
        else{
            return true;
        }
    }

    public func savePasswordFile(){
        print("PasswordItem savePasswordFile");

        let dicArray = convertToDictionaryArray();
        let data : Data? = try? JSONSerialization.data(withJSONObject: dicArray, options: JSONSerialization.WritingOptions.prettyPrinted)
      
        let encryptedData = encryptData(data!, key: encryptionKey!);
        //save file
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let path = (paths as NSString).appendingPathComponent("passwords.dat")
        do {
            try encryptedData?.write(to: URL(fileURLWithPath: path), options:NSData.WritingOptions.completeFileProtection)
        } catch _ {
        }
     
    }
    
    public func changePassword(_ passcode: String){
        print("PasswordItem changePassword");
        let saltStr : String = "salt"
        let salt = saltStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        lastUsedEncrytionKey = encryptionKey;
        savePasswordFile()
    }
 
    func copyPasswordFile(_ sourcePath : String, err: NSErrorPointer){
        var error : NSError?
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let path = (paths as NSString).appendingPathComponent("passwords.dat")
        if (isPasswordFileExisting()){
            do {
                try fileManager.removeItem(atPath: path)
            } catch let error1 as NSError {
                error = error1
            }
        }
        if let e = error {
            err?.pointee = e
        }
        else{
            do {
                //copy the file
                try fileManager.moveItem(atPath: sourcePath, toPath: path)
            } catch let error1 as NSError {
                error = error1
            }
            do {
                try fileManager.removeItem(atPath: sourcePath)
            } catch _ {
            }
      
            if let e = error {
                err?.pointee = e
               
            }
            else{
                self.encryptionKey = nil
                self.lastUsedEncrytionKey = nil
                NotificationCenter.default.post(name: Notification.Name(rawValue: "passwordFileChanged"), object: nil)
            }
        }
    }


    //MARK: public function will change the password item list content
    public func addPasswordItem(_ item: PasswordItem) -> [PasswordItem]{
        resetCachedFilterResult()
        passwordList?.append(item)
        savePasswordFile()
        return passwordList!
    }
    
    public func deletePasswordItem(_ item : PasswordItem){
        resetCachedFilterResult()
        for index in 0..<self.passwordList!.count {
            if ( item.id == self.passwordList![index].id){
                self.passwordList?.remove(at: index);
                break;
            }
        }
    }
    
    public func loadPasswordFileWithLastUsedEncryptionKey() -> Bool {
        resetCachedFilterResult()
         if let savedKey = self.lastUsedEncrytionKey {
             encryptionKey = savedKey;
             return loadPasswordFileWithEncryptionKey();
         }
         return false;
    }
    
    public func loadPasswordFile(_ passcode : String) -> Bool{
        resetCachedFilterResult()
        let saltStr : String = "salt"
        let salt = saltStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        return loadPasswordFileWithEncryptionKey();
    }
    
    public func unloadPasswordFile() {
        print("PasswordItems UnloadPasswordFile")
        resetCachedFilterResult()
        encryptionKey = nil
        passwordList = nil
    }
    
    //create the initial password file
    public func createPasswordFile(_ passcode: String){
        resetCachedFilterResult()
        passwordList = [];
        
        let saltStr : String = "salt"
        let salt = saltStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
        encryptionKey = getKeyFromPassword(passcode, salt: salt!)
        self.lastUsedEncrytionKey  = encryptionKey;
        savePasswordFile()
        
    }



}
