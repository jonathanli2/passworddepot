//
//  passwordwalletTests.swift
//  passwordwalletTests
//
//  Created by Li, Jonathan on 2018-05-19.
//  Copyright © 2018 Mobi Solution. All rights reserved.
//

import XCTest

class passwordwalletTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetKey() {
        var password = "password"
        var salt = "salt"
        var derivedKey : NSMutableData = NSMutableData(length: 64)!
        var passwordData = NSString(string: password).utf8String
        var passwordDataSize = password.utf8.count
        var saltData = NSString(string: salt).utf8String
        var saltDataSize = salt.utf8.count
        var saltDataPointer = UnsafeRawPointer(saltData!).bindMemory(to:UInt8.self, capacity:saltDataSize)
  
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordData,
                             passwordDataSize, saltDataPointer, saltDataSize,
                             CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                             uint(100),
                             UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes.assumingMemoryBound(to:UInt8.self)),
                             derivedKey.length)
        
        print( "password: \(password), passwordData:\(password.utf8CString) size: \(passwordDataSize), salt: \(salt), saltData: \(salt.utf8CString) size: \(saltDataSize), key: \(derivedKey)");
       //password: password, passwordData:[112, 97, 115, 115, 119, 111, 114, 100, 0] size: 8, salt: salt, saltData: [115, 97, 108, 116, 0] size: 4, key: <fef7276b 107040a0 a713bcbe c9fd3e19 1cc61532 49e245a3 e1a22087 dbe61606 0bbfc841 1c6363f3 c10ab5d0 2a56c38e 2066a4e2 05b0ca8f 959fd731 e5fa584b>
        
        password = "密码"
        salt = "盐"
        derivedKey = NSMutableData(length: 64)!
        passwordData = NSString(string: password).utf8String
        passwordDataSize = password.utf8.count
        saltData = NSString(string: salt).utf8String
        saltDataSize = salt.utf8.count
        saltDataPointer = UnsafeRawPointer(saltData!).bindMemory(to:UInt8.self, capacity:saltDataSize)
        
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordData,
                             passwordDataSize, saltDataPointer, saltDataSize,
                             CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                             uint(100),
                             UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes.assumingMemoryBound(to:UInt8.self)),
                             derivedKey.length)
        
        print( "password: \(password), passwordData:\(password.utf8CString) size: \(passwordDataSize), salt: \(salt), saltData: \(salt.utf8CString) size: \(saltDataSize), key: \(derivedKey)");
        //password: 密码, passwordData:[-27, -81, -122, -25, -96,-127, 0] size: 6, salt: 盐, saltData: [-25, -101, -112, 0] size: 3, key: <22711d36 bbcca72a fa19c6a6 553a6a79 23ad9ab4 9ec21f16 f019b17b a1be7993 5128096b 12a84b7c 6e9f5616 92e304f2 125778b7 4901d24a ef9f3338 7d207ad2>
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
