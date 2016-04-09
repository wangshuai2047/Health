//
//  ConvertData.swift
//  Health
//
//  Created by Yalin on 15/9/4.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

extension NSData {
    
    func getUInt16Bytes(inout buffer: UInt16, range: NSRange) {
        let count = range.length / sizeof(UInt8)
        // create array of appropriate length:
        var bytes = [UInt8](count: count, repeatedValue: 0)
        // copy bytes into array
        self.getBytes(&bytes, range: range)
        
        var outBuffer: [UInt8] = []
        for var i = count - 1; i >= 0; i-- {
            outBuffer += [bytes[i]]
        }
        buffer = UnsafePointer<UInt16>(outBuffer).memory
    }
    
    func getBytes<T>(inout buffer buffer: T, range: NSRange) {
        let count = range.length
        // create array of appropriate length:
        var bytes = [UInt8](count: count, repeatedValue: 0)
        // copy bytes into array
        self.getBytes(&bytes, range: range)
        
        var outBuffer: [UInt8] = []
        for var i = count - 1; i >= 0; i -= 1 {
            outBuffer += [bytes[i]]
        }
        buffer = UnsafePointer<T>(outBuffer).memory
    }
}