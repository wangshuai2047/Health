//
//  Crypto.swift
//  Health
//
//  Created by Yalin on 15/9/8.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation


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
        let original_str = NSString(string: self).dataUsingEncoding(NSUTF8StringEncoding)!.bytes
        
        var result: [CUnsignedChar] = [CUnsignedChar](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(original_str, CC_LONG(self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.length), &result)
        
        let hash = NSMutableString()
        for index in 0...15 {
            hash.appendFormat("%02x", result[index])
        }
        
        return String(hash.lowercaseString)
    }
}