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
    
    init(id:String, userName:String, password:String, link:String, note:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = link
        self.note = note
    }
    
      init(id:String, userName:String, password:String, link:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = link
    }

      init(id:String, userName:String, password:String){
        self.id = id
        self.userName = userName
        self.password = password
        self.link = nil
    }
    
    static var passwordList : [PasswordItem]?
    
    class func getPasswordItemList() -> [PasswordItem] {
        if let list = passwordList {
            return list
        }
        else{
            passwordList =  [];
             passwordList!.append(PasswordItem(id: "git", userName: "jonathanli2", password: "Qpalmzmz9", link:"https://github.com/jonathanli2", note:"old password: Abcd1234"))
            passwordList!.append(PasswordItem(id: "gmail", userName: "jonathanli2000@gmail.com", password: "Qpalmzmz9", link:"https://mail.google.com"))
            passwordList!.append(PasswordItem(id: "yahoo", userName: "Andrew", password: "Abcd"))
            passwordList!.append(PasswordItem(id: "CIBC", userName: "John", password: "money$$$", link:"https://www.cibc.com/login"))
            passwordList!.append(PasswordItem(id: "it21learning", userName: "macbook", password: "cable"))
            passwordList!.append(PasswordItem(id: "Rogers", userName: "Elena", password: "toronto"))
            return passwordList!
        }
    }
    
    class func addPasswordItem(item: PasswordItem) -> [PasswordItem]{
        passwordList?.append(item)
        return passwordList!
    }
    
    class func deletePasswordItem(item : PasswordItem){
    
        for (var index = 0; index < self.passwordList!.count; index++) {
            if ( item.id == self.passwordList![index].id){
                self.passwordList?.removeAtIndex(index);
                break;
            }
        }
        
    }
}