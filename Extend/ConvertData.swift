//
//  ConvertData.swift
//  Health
//
//  Created by Yalin on 15/9/4.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

extension Data {
    
    func getUInt16Bytes(_ buffer: inout UInt16, range: NSRange) {
        
        
        
        let count = range.length / MemoryLayout<UInt8>.size
        // create array of appropriate length:
        var bytes = [UInt8](repeating: 0, count: count)
        // copy bytes into array
        (self as NSData).getBytes(&bytes, range: range)
        
        var outBuffer: [UInt8] = []
        for i in count-1...0 {
            outBuffer += [bytes[i]]
        }
        
        buffer = UnsafePointer(outBuffer).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
    }
    
    func getBytes<T>(buffer: inout T, range: NSRange) {
        let count = range.length
        // create array of appropriate length:
        var bytes = [UInt8](repeating: 0, count: count)
        // copy bytes into array
        (self as NSData).getBytes(&bytes, range: range)
        
        var outBuffer: [UInt8] = []
        for i in count-1...0 {
            outBuffer += [bytes[i]]
        }
        
        buffer = UnsafePointer(outBuffer).withMemoryRebound(to: T.self, capacity: 1) {
            $0.pointee
        }
    }
}
