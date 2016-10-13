//
//  Crypto.swift
//  Health
//
//  Created by Yalin on 15/9/8.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation
//import CommonCrypto

/*
/*
* MD5
*/
CG_INLINE NSString* MD5FromString(NSString *sourceString)
{
    const char *original_str = [sourceString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
    [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
*/

extension String {
    var md5Value: String {
        
//        print("md5 String: \(self)")
        let original_str = self.cString(using: String.Encoding.utf8)
//        let original_str = (NSString(string: self).data(using: String.Encoding.utf8)! as NSData).bytes
        
        var result: [CUnsignedChar] = [CUnsignedChar](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(original_str, CC_LONG(self.data(using: String.Encoding.utf8, allowLossyConversion: false)!.count), &result)
        
        let hash = NSMutableString()
        for index in 0...15 {
            hash.appendFormat("%02x", result[index])
        }
        
        return String(hash.lowercased)
    }
}
