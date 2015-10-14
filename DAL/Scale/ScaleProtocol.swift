//
//  ScaleProtocol.swift
//  Health
//
//  Created by Yalin on 15/8/29.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

protocol ScaleDelegate {
    func scanDevice(scale: ScaleProtocol)
    
    // 测量到结果回调
    func scaleResult(result: ScaleResultProtocol)
}

protocol ScaleProtocol {
    var delegate: ScaleDelegate? {get set}
    var isConnectDevice: Bool {get}
    
    func scanDevice(complete: ((scale: ScaleProtocol)-> Void))
    func scanCancel()
    
    func setScaleData(userId: Int, gender: Bool, age: UInt8, height: UInt8)
    
    func startScale(complete: (result: ScaleResultProtocol?, err: NSError?) -> Void)
    static func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol
    func stopScale()
}