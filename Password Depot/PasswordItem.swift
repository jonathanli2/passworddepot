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
    var url : String? = nil
    
    init(id:String, userName:String, password:String){
        self.id = id
        self.userName = userName
        self.password = password
    }
    
    
    static var passwordList : [PasswordItem]?
    
    class func getPasswordItemList() -> [PasswordItem] {
        if let list = passwordList {
            return list
        }
        else{
            passwordList =  [];
            passwordList!.append(PasswordItem(id: "google", userName: "jonathan", password: "password"))
            passwordList!.append(PasswordItem(id: "yahoo", userName: "Andrew", password: "Abcd"))
            passwordList!.append(PasswordItem(id: "CIBC", userName: "John", password: "money$$$"))
            passwordList!.append(PasswordItem(id: "it21learning", userName: "macbook", password: "cable"))
            passwordList!.append(PasswordItem(id: "Rogers", userName: "Elena", password: "toronto"))
            return passwordList!
        }
    }
    
    class func addPasswordItem(item: PasswordItem) -> [PasswordItem]{
            passwordList?.append(item)
            return passwordList!
    }
}