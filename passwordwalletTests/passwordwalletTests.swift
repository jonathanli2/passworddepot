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
    
    func stringToData(str : String) -> Data {
        var hex = str
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    func testGetKey() {
        var password = "password"
        var salt = "salt"
        var derivedKey : NSMutableData = NSMutableData(length: kCCKeySizeAES256)!
        var passwordData = NSString(string: password).utf8String
        var passwordDataSize = password.utf8.count
        var saltData = NSString(string: salt).utf8String
        var saltDataSize = salt.utf8.count
        var saltDataPointer = UnsafeRawPointer(saltData!).bindMemory(to:UInt8.self, capacity:saltDataSize)
  
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordData,
                             passwordDataSize, saltDataPointer, saltDataSize,
                             CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                             uint(100),
                             UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes.assumingMemoryBound(to:UInt8.self)),
                             derivedKey.length)
      
        var hexData = derivedKey.description
        hexData = hexData.replacingOccurrences(of: " ", with: "")
        hexData = hexData.replacingOccurrences(of: ">", with: "")
        hexData = hexData.replacingOccurrences(of: "<", with: "")
        assert(hexData == "07e6997180cf7f12904f04100d405d34888fdf62af6d506a0ecc23b196fe99d8", "key bytes not equal")
        print( "password: \(password), passwordData:\(password.utf8CString) size: \(passwordDataSize), salt: \(salt), saltData: \(salt.utf8CString) size: \(saltDataSize), key: \(derivedKey)");
        
        let dataStr = "this is a testing string"
        let data : Data = dataStr.data(using: String.Encoding.utf8)!
        var encryptedData = testEncryption(encryptionKey: derivedKey as Data, dataToEncrypt: data)
        
        if (encryptedData != nil) {
        
            hexData = encryptedData!.description
            hexData = hexData.replacingOccurrences(of: " ", with: "")
            hexData = hexData.replacingOccurrences(of: ">", with: "")
            hexData = hexData.replacingOccurrences(of: "<", with: "")
            assert(hexData == "92a78f657da19a444e28c83f604a63401dc9a81300dcf4b2707fe66a9d62f158", "encrypted data not equal")
        }
        else {
            assert(false, "Fail to encrypt data")
        }
        
        //decrypt data
        let encryptedStr = "92a78f657da19a444e28c83f604a63401dc9a81300dcf4b2707fe66a9d62f158"
        let encryptedDataObj = stringToData(str: encryptedStr)
        let decryptedDataObj = testDecryption(encryptionKey: derivedKey as Data, dataToDecrypt: encryptedDataObj)
        let originalStr = String(data: decryptedDataObj! as Data, encoding:  String.Encoding.utf8)
        assert( originalStr == dataStr)
        
        
        password = "密码"
        salt = "盐"
        derivedKey = NSMutableData(length: kCCKeySizeAES256)!
        passwordData = NSString(string: password).utf8String
        passwordDataSize = password.utf8.count
        saltData = NSString(string: salt).utf8String
        saltDataSize = salt.utf8.count
        saltDataPointer = UnsafeRawPointer(saltData!).bindMemory(to:UInt8.self, capacity:saltDataSize)
        
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordData,
                             passwordDataSize, saltDataPointer, saltDataSize,
                             CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                             uint(100),
                             UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes.assumingMemoryBound(to:UInt8.self)),
                             derivedKey.length)
        
        hexData = derivedKey.description
        hexData = hexData.replacingOccurrences(of: " ", with: "")
        hexData = hexData.replacingOccurrences(of: ">", with: "")
        hexData = hexData.replacingOccurrences(of: "<", with: "")
        assert(hexData == "900f8719f665396369c409f67d05e222b173f87b648208338a8dc4376fdd84d6", "2 key bytes not equal")
        
        print( "password: \(password), passwordData:\(password.utf8CString) size: \(passwordDataSize), salt: \(salt), saltData: \(salt.utf8CString) size: \(saltDataSize), key: \(derivedKey)");
    
        encryptedData = testEncryption(encryptionKey: derivedKey as Data, dataToEncrypt: data)
        
        if (encryptedData != nil) {
        
            hexData = encryptedData!.description
            hexData = hexData.replacingOccurrences(of: " ", with: "")
            hexData = hexData.replacingOccurrences(of: ">", with: "")
            hexData = hexData.replacingOccurrences(of: "<", with: "")
            assert(hexData == "ba78951a54989341c4468cac8d39f54d67cdd7b0aa68be3bd5881a1027e9a1a7", "key bytes not equal")
        }
        else {
            assert(false, "Fail to encrypt data")
        }
    }
    
    func testDecryption(encryptionKey: Data, dataToDecrypt: Data) -> NSData? {
        var outLength : size_t = 0;
        let cipherData : NSMutableData? = NSMutableData(length: dataToDecrypt.count );
        let ivb : [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let iv = NSData(bytes: ivb, length: 16)
        let result = CCCrypt(            UInt32(kCCDecrypt), // operation
            UInt32(kCCAlgorithmAES128), // algorithm
            UInt32(kCCOptionPKCS7Padding), // options
            (encryptionKey as NSData).bytes, // key
            encryptionKey.count, // keylength
            iv.bytes, // iv
            (dataToDecrypt as NSData).bytes, // dataIn
            dataToDecrypt.count, // dataInLength,
            UnsafeMutablePointer<UInt8>(cipherData!.mutableBytes.assumingMemoryBound(to:UInt8.self)), // dataOut
            cipherData!.length, // dataOutAvailable
            &outLength); // dataOutMoved
        
        if (UInt32(result) == UInt32(kCCSuccess)) {
            cipherData!.length = outLength;
            return cipherData;
        }
        else {
            return nil
        }
        
    }

    func testEncryption(encryptionKey: Data, dataToEncrypt: Data) -> NSData? {

        var outLength : size_t = 0;
        let cipherData : NSMutableData? = NSMutableData(length: dataToEncrypt.count + kCCBlockSizeAES128);
        let ivb : [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let iv = NSData(bytes: ivb, length: 16)
        let result = CCCrypt(            UInt32(kCCEncrypt), // operation
            UInt32(kCCAlgorithmAES128), // algorithm
            UInt32(kCCOptionPKCS7Padding), // options
            (encryptionKey as NSData).bytes, // key
            encryptionKey.count, // keylength
            iv.bytes, // iv
            (dataToEncrypt as NSData).bytes, // dataIn
            dataToEncrypt.count, // dataInLength,
            UnsafeMutablePointer<UInt8>(cipherData!.mutableBytes.assumingMemoryBound(to:UInt8.self)), // dataOut
            cipherData!.length, // dataOutAvailable
            &outLength); // dataOutMoved
        
        if (UInt32(result) == UInt32(kCCSuccess)) {
            cipherData!.length = outLength;
            return cipherData;
        }
        else {
            return nil
        }
        
    }
    
}
