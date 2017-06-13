//
//  MyBodyMiniWhiteManager.swift
//  Health
//
//  Created by 王帅 on 16/10/14.
//  Copyright © 2016年 Yalin. All rights reserved.
//


import UIKit
import CoreBluetooth

class MyBodyMiniWhiteManager: NSObject, DeviceManagerProtocol {
    
    internal func fire(_ info: [String : Any], complete: @escaping (ResultProtocol?, Error?) -> Void) {
        self.fireComplete = complete
        self.fireInfo = info
        
        if let userModel = fireInfo?["userModel"] as? UserModel {
            self.result = MyBodyMiniWhiteResult(dataId: UUID().uuidString, userId: userModel.userId, gender: userModel.gender, age: userModel.age, height: userModel.height)
        }
        else {
            print("MyBodyMiniWhiteManager fire error: info参数不对 没有userModel字段")
            fireComplete?(nil, NSError(domain: "MyBodyMiniWhiteManager fire error", code: 0, userInfo: [NSLocalizedDescriptionKey:"fire info参数不对 没有userModel字段"]))
        }
    }
    
    
    var name: String
    var uuid: String
    var RSSI = NSNumber(value: 0 as Int)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.myBodyMiniWhite
    
    var serviceUUID: String { return "BCA0" }
    var characteristicUUID: [String] { return ["BCA1","BCA2"] }
    
    var result: MyBodyMiniWhiteResult?
    
    var notifyCharacteristic: CBCharacteristic?//bca1
    var writeCharacteristic: CBCharacteristic?//bca2
    
    var fireInfo: [String : Any]?
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?

    var array = [UInt8]()
    
    var count = 0
    
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    
    func getValue(pre:UInt8,QB:UInt8,SG:UInt8,XS:UInt8) -> Float {
        
        let th :Float = Float(QB) * 100;
        let dotValue:Float = Float(XS)/100;
        let value =  th + Float(SG) + dotValue;
        if pre == 0 {
            return value;
        }
        return value * -1;
    }
    
    
    fileprivate func reveiveData(_ data: Data) {
        
        var arraySub = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start:$0,count:data.count))
        }
        print("%@",arraySub)
        
        let info = arraySub[3]
        //info & 0xf1 第一位
        //info & 0xf2 第二位
        //info & 0xf4 第三位
        
        let first = info & 0x01//第一位(最低位)为 1 表示测试失败,为 0 表示测试成功
        let second = (info & 0x02)>>1//第二位为 1 表示不是最后一包数据,还有后续包数据;为 0 表示是最后一包数据,没有后续包;
        let third = (info & 0x04)>>2//第三位为 1 表示有脂肪肝,为 0 表示没有脂肪肝;
        
        //去掉包头
        arraySub.remove(at: 0)
        arraySub.remove(at: 0)
        arraySub.remove(at: 0)
        arraySub.remove(at: 0)
        
        //去掉包尾
        arraySub.removeLast()
        arraySub.removeLast()
        arraySub.removeLast()
        arraySub.removeLast()
        
        //加入大数组
        array.append(contentsOf: arraySub)
        NSLog("array:\(array)")
        // 判断是否为最后一包
        if second == 0
        {
            
            self.fireComplete?(nil,nil)
            //最后一包,判断测试是否成功
            if first == 0
            {//测试成功
                
                let userModel = fireInfo?["userModel"] as? UserModel
                var result: MyBodyMiniWhiteResult? = MyBodyMiniWhiteResult(dataId: UUID().uuidString, userId: userModel!.userId, gender: userModel!.gender, age: userModel!.age, height: userModel!.height)
                //支持脂肪肝
                result?.hepaticAdiposeInfiltration = true
                var index = 0;
                //体重
                let weight = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.weight = weight
                print("体重:%f",weight)
                
                //标准体重  和标准体重上下限
                if userModel?.gender == true {//男
                    result?.SW = 0.00452 * Float(userModel!.height) * Float(userModel!.height) - 0.55564 * Float(userModel!.height) + 26.36570
                    result?.SWRange = (0.9 * result!.SW, 1.1 * result!.SW)
                } else {//女
                    result?.SW = 0.00465 * Float(userModel!.height) * Float(userModel!.height) - 0.59980 * Float(userModel!.height) + 29.99886
                    result?.SWRange = (0.9 * result!.SW, 1.1 * result!.SW)
                }
                
                //健康评分
                let goal = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.score = goal
                print("健康评分:%f",goal)
                //内脏脂肪
                let nzzf = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.visceralFatPercentage = nzzf
                print("内脏脂肪:%f",nzzf)
                //基础代谢率
                let dx = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.BMR = dx
                print("基础代谢率:%f",dx)
                //身体年龄
                let nl = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.bodyAge = nl
                print("身体年龄:%f",nl)
                //肌肉
                let jr = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.muscleWeight = jr
                print("肌肉:%f",jr)
                //肌肉正常范围下限
                let jr_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("肌肉正常范围下限:%f",jr_min)
                //肌肉正常范围上限
                let jr_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("肌肉正常范围上限:%f",jr_max)
                result?.muscleWeightRange = (jr_min,jr_max)
                
                //蛋白质
                let dbz = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.proteinWeight = dbz
                print("蛋白质:%f",dbz)
                //蛋白质正常范围下限
                let dbz_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("蛋白质正常范围下限:%f",dbz_min)
                //蛋白质正常范围上限
                let dbz_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("蛋白质正常范围上限:%f",dbz_max)
                result?.proteinWeightRange = (dbz_min,dbz_max)
                
                //骨量(两位小数)
                let gl = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("骨量:%f",gl)
                result?.boneWeight = gl
                //骨量正常范围下限
                let gl_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("骨量正常范围下限:%f",gl_min)
                //骨量正常范围上限
                let gl_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("骨量正常范围上限:%f",gl_max)
                result?.boneWeightRange = (gl_min,gl_max)
                
                //总水
                let zs = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.waterWeight = zs
                print("总水:%f",zs)
                //总水正常范围下限
                let zs_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("总水正常范围下限:%f",zs_min)
                //总水正常范围上限
                let zs_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("总水正常范围上限:%f",zs_max)
                result?.waterWeightRange = (zs_min,zs_max)
                
                //脂肪
                let zf = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.fatWeight = zf
                print("脂肪:%f",zf)
                //脂肪正常范围下限
                let zf_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("脂肪正常范围下限:%f",zf_min)
                //脂肪正常范围上限
                let zf_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("脂肪正常范围上限:%f",zf_max)
                result?.fatWeightRange = (zf_min/100,zf_max/100)
                
                //体脂率
                let tzl = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.fatPercentage = tzl
                print("体脂率:%f",tzl)
                //体脂率正常范围下限
                let tzl_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("体脂率正常范围下限:%f",tzl_min)
                //体脂率正常范围上限
                let tzl_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("体脂率正常范围上限:%f",tzl_max)
                result?.fatPercentageRange = (tzl_min/100,tzl_max/100)
                
                //BMI
                let bmi = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.BMI = bmi
                print("BMI:%f",bmi)
                //BMI 正常范围下限
                let bmi_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("BMI 正常范围下限:%f",bmi_min)
                //BMI 正常范围上限
                let bmi_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("BMI 正常范围上限:%f",bmi_max)
                result?.BMIRange = (bmi_min,bmi_max)
                
                //骨骼肌
                let ggj = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                result?.boneMuscleWeight = ggj
                print("骨骼肌:%f",ggj)
                //骨骼肌正常范围下限
                let ggj_min = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                index += 4;
                print("骨骼肌正常范围下限:%f",ggj_min)
                //print("%d",index);
                //骨骼肌正常范围上限
                let ggj_max = self.getValue(pre: array[index], QB: array[index + 1], SG: array[index + 2], XS: array[index + 3]);
                print("骨骼肌正常范围上限:%f",ggj_max)
                result?.boneMuscleRange = (ggj_min,ggj_max)
                
                DispatchQueue.main.async {
                    self.fireComplete?(result,nil);
                }
 
            }
            else
            {//测试失败
                var error: NSError? = nil
                error = NSError(domain: "MyBodyMiniWhiteManager", code: 99, userInfo: [NSLocalizedDescriptionKey : "请重新测试"])
                fireComplete?(result, error)
            }
            
            //错误格式8f
//            let rs : [UInt8] = [0x8f];
//            let data:Data = Data(rs);
//            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
        }
        else//不是最后一包数据,还有后续包数据
        {
            
            /*
             将数据的包头包尾全部去掉只剩数据，将数据加入集合
             */
            
            
        }
        
        
       
    }
}

extension MyBodyMiniWhiteManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        fireComplete?(nil, error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        fireComplete?(nil, error as NSError?)
    }
}

extension MyBodyMiniWhiteManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //        NSLog("search service UUID %@", service.characteristics!)
        if error == nil && service.characteristics != nil {
            for characteristic in service.characteristics! {
                
                if CBUUID(string: "BCA1") == characteristic.uuid {
                    
                    if characteristic.properties == CBCharacteristicProperties.notify
                    {
                        self.notifyCharacteristic = characteristic
                        
                        //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                        
                        self.peripheral?.setNotifyValue(true, for: self.notifyCharacteristic!)
                        
                        
                        //                    }
                        
                        
                        
                        //                    //                    self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
                        //                    //                    self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
                        //                    //                    self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
                        //
                        //                    //                    dispatch_after(dispatch_time_t(1), dispatch_get_main_queue(), { [unowned self] () -> Void in
                        //                    //
                        //                    //                        if self.readCharacteristic?.properties == CBCharacteristicProperties.Notify {
                        //                    //                            self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
                        //                    //                        }
                        //                    //
                        //                    //                    })
                    }
                    

                }
                else if CBUUID(string: "BCA2") == characteristic.uuid {
                    
                    if characteristic.properties ==  CBCharacteristicProperties.write
                    {
                        self.writeCharacteristic = characteristic
                        if let userModel = fireInfo?["userModel"] as? UserModel {
                            //                        self.peripheral?.setNotifyValue(true, forCharacteristic: self.writeCharacteristic!)
                            
                            //                        dispatch_after(dispatch_time_t(1), dispatch_get_main_queue(), { [unowned self] () -> Void in
                            
                            //写测试者信息
                            let setUserData = MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.setUserData).toSetUserData(userModel.gender, age: userModel.age, height: userModel.height)
                            NSLog("write user data: \(setUserData)")
                            self.peripheral?.writeValue(setUserData, for: self.writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                            
                            //  })
                            
                        }
                    }
                    
                    
                }
            }
            
            
        }
        else {
            // 调用失败代理
            NSLog("didDiscoverCharacteristicsForService error \(error!)")
            fireComplete?(nil, error as NSError?)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error == nil && characteristic.value != nil {
            NSLog("接收到数据: \(characteristic.value)")
            
            count += 1
            print("count = \(count)")
            
            //发送8f
            let receiveWeightData = MybodyMiniWhiteBlueToothFormats(cmd:MybodyMiniWhiteBlueToothFormats.CMD.receiveData).toReceiveWeightData()
            self.peripheral?.writeValue(receiveWeightData, for: self.writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
            //解析数据
            reveiveData(characteristic.value!)
            
            
        }
        else {
            // 调用失败代理
            NSLog("didUpdateValueForCharacteristic error \(error!)")
            fireComplete?(nil, error as NSError?)
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            NSLog("didWriteValueForCharacteristic \(error!)")
            // 调用失败代理
            fireComplete?(nil, error as NSError?)
        }
        else {

//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
//                self.peripheral?.setNotifyValue(true, for: self.notifyCharacteristic!)
//            }
            
            //在此等response
            print("write char: \(self.writeCharacteristic)")
            print("write char: \(characteristic)")
            
            
            
            
            //            print("read char: \(self.readCharacteristic)")
            
            //            self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
            //            fireComplete?(nil, error)
            //            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1), execute: { [unowned self] () -> Void in
            ////                    self.peripheral?.setNotifyValue(true, for: self.notifyCharacteristic!)
            //
            ////                    self.peripheral?.readValue(for: self.readCharacteristic!)
            //                })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("notification state changed 这里不要写任何东西 这是信道状态改变的回调")
        NSLog("%@", self.notifyCharacteristic!)
        
        
        
    }
    
}





