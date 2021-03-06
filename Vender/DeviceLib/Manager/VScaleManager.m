//
//  VScaleManager.m
//  VScale_Sdk_Demo
//
//  Created by Ben on 13-10-10.
//  Copyright (c) 2013年 Vtrump. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "VScaleManager.h"

#define KEY_MODEL_NUMBER    @"modelNumber"

@interface VScaleManager(){
    VTDeviceManager *deviceManager;
    VTDeviceModel *deviceModel;
    NSMutableArray *serviceUUID;
    
    NSMutableArray *_scanDeviceCompletes;
    NSTimer *_scanDeviceTimer;
    
    
    void (^_scaleComplete)(VTFatScaleTestResult *result, NSError *error);
}

@end

@implementation VScaleManager



static VScaleManager *instance = nil;

+(VScaleManager *)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self){
        /* init test result */
        self.scaleResult = [[VTFatScaleTestResult alloc]init];
        self.curStatus = VCStatusDisconnected;
        
        deviceManager = [VTDeviceManager sharedInstance];
        deviceManager.delegate = self;
        
        serviceUUID = [NSMutableArray array];
//         cGetServiceUUID;
        
        NSLog(@"[VScaleManager]init scanning %@", deviceManager.historyList);
        
        _scanDeviceCompletes = [NSMutableArray array];
    }
    
    return self;
}

- (NSString *)deviceUUID {
    return deviceModel.UUID;
}

- (NSString *)name {
    return deviceModel.name;
}

-(void)scan
{
    [deviceManager scan:serviceUUID];
}

- (void)scanDevice:(void (^)(NSError *error))complete
{
    [_scanDeviceCompletes addObject:[complete copy]];
    [deviceManager scan:serviceUUID];
    
//    _scanDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(scanDeviceTimeOut) userInfo:nil repeats:NO];
}

- (void)scale:(void (^)(VTFatScaleTestResult *result, NSError *error))complete
{
    _scaleComplete = complete;
    [self connect];
}

- (void)connect
{
    [deviceModel  connect];
}

- (void)disconnect
{
    NSLog(@"disconnect status = %lu", (unsigned long)self.curStatus);
    if (self.curStatus != VCStatusDisconnected && self.curStatus!=VCStatusDiscovered){
        NSNumber * modelNumber = (NSNumber *)[deviceModel getMetaData:KEY_MODEL_NUMBER defaultValue:nil];
        
        if (modelNumber == nil){
            [deviceModel disconnect];
        }else{
            NSInteger modelNumberInt = [modelNumber integerValue];
            if (Format_ModelNumber_Version_Type(modelNumberInt) == SCALE_VERSION_TYPE_VALID_VALUE){
                [deviceModel.profile suspendDevice:deviceModel];
            }else{
                [deviceModel disconnect];
            }
        }
    }
}

- (void)setCalulateDataWithUserID:(UInt8)userID gender:(UInt8)gender age:(UInt8)age height:(UInt8)height
{
    _userID = userID;
    _gender = gender;
    _age = age;
    _height = height;
}

- (void)scanDeviceTimeOut {
    
    NSArray *tempCompletes = [NSArray arrayWithArray:_scanDeviceCompletes];
    [_scanDeviceCompletes removeAllObjects];
    for (void (^_scanDeviceComplete)(NSError *error) in tempCompletes) {
        _scanDeviceComplete([NSError errorWithDomain:@"VScaleManager" code:0 userInfo:@{NSLocalizedDescriptionKey : @"搜索设备超时"}]);
    }
}

#pragma mark -
#pragma mark private method
- (void) gotoStatus:(VCStatus) status{
    
    self.curStatus = status;
    
    [self.delegate updateDeviceStatus:status];  
}

- (UILocalNotification*) scheduleNotificationOn:(NSDate*) fireDate
                                           text:(NSString*) alertText
                                         action:(NSString*) alertAction
                                          sound:(NSString*) soundfileName
                                    launchImage:(NSString*) launchImage
                                        andInfo:(NSDictionary*) userInfo
                                        counted:(BOOL)counted
                                 repeatInterval:(NSCalendarUnit)repeat
                                 enableAtActive:(BOOL)enable


{
    if(enable == NO)
    {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            return nil;
    }
    
    
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.alertBody = alertText;
    localNotification.alertAction = alertAction;
    
    if(repeat != 0){
        localNotification.repeatInterval = repeat;
    }
    
	if(soundfileName == nil)
	{
		localNotification.soundName = nil;
	}
	else
	{
		localNotification.soundName = soundfileName;
	}
    
	localNotification.alertLaunchImage = launchImage;
    
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.userInfo = userInfo;
    
	// Schedule it with the app
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    return localNotification;
}

#pragma mark -
#pragma mark VTProfileDelegate implemenation
- (void) didTestResultValueUpdate:(VTDeviceModel *)device scaleType:(UInt8)scaleType result:(id)result
{
    
    NSLog(@"didTestResultValueUpdate");
    
    if(result != nil){
        switch (scaleType) {
            case VT_VSCALE_FAT:{
                self.scaleResult = result;
                if (self.scaleResult.weight == 0.0) return;
                
                switch (self.curStatus) {
                    case VCStatusServiceReady:{
                        [self gotoStatus:VCStatusHolding];
                        NSLog(@"VC_STATUS_SERVICE_READY done");
                        [self.delegate updateUIDataWithFatScale:self.scaleResult];
                        
                        VTScaleUser *_currentUser = [[VTScaleUser alloc] init];
                        _currentUser.userID = _userID; // Use slot 9 for caculate
                        _currentUser.gender = _gender; //0代表男性、1代表女性
                        _currentUser.age = _age;  //年龄
                        _currentUser.height = _height;  //身高
                        [deviceModel.profile caculateResult:deviceModel user:_currentUser];
                        [self gotoStatus:VCStatusCaculate];
                    }
                        break;
                    case VCStatusCaculate:{
                        NSLog(@"VC_STATUS_CACULATING done");
                        [self gotoStatus:VCStatusCaculate];
                        [self.delegate updateUIDataWithFatScale:self.scaleResult];
                        [deviceModel disconnect];
                        
                        
                        NSError *error = nil;
                        if ([(VTFatScaleTestResult *)result waterContent] == 0) {
                            error = [NSError errorWithDomain:@"VScale Error" code:1 userInfo:@{NSLocalizedDescriptionKey : @"测试失败"}];
                        }
                        
                        if (_scaleComplete) {
                            _scaleComplete(result, error);
                        }
                        
                        [self gotoStatus:VCStatusServiceReady];
                    }
                        break;
                    case VCStatusHolding:
                        NSLog(@"VC_STATUS_HOLDING done");
                        [self gotoStatus:VCStatusHolding];
                        // ignored
                        ;
                        break;
                    default:
                        break;
                }
            }
                
                break;
                
            case VT_VSCALE_WEIGHT:{
                self.scaleResult = result;
                if (self.scaleResult.weight == 0.0) return;

                switch (self.curStatus) {
                    case VCStatusServiceReady:{
                        [self.delegate updateUIDataWithWeightScale:self.scaleResult];
                        
                    }
                        break;
                    case VCStatusHolding:
                        break;
                    default:
                        break;
                }
                
            }
                
                break;
            default:
                break;
        }
        
    }
}

#pragma mark -
#pragma mark VTDeviceManagerDelegate implementation

- (Boolean) didDiscovered:(VTDeviceManager *)dm device:(VTDeviceModel *)device{
    NSLog(@"didDiscovered");
    if ([device.UUID isEqualToString:@"4588E96E-AE96-1950-FB77-9D76F3284961"]) {
        return YES;
    }
    return NO;
}

- (void)didConnected:(VTDeviceManager *)dm device:(VTDeviceModel *)device{
    NSLog(@"didConnected");
    deviceModel = device;
}

- (void) didStatusUpdate:(CBCentralManagerState) status{
    NSLog(@"didStatusUpdate %ld",(long)status);
    if (status == 5) {
        [self scan];
    }
}

- (void)didDisconnected:(VTDeviceManager *)dm device:(VTDeviceModel *)device{
    
    NSLog(@"didDisconnected");
    [self gotoStatus:VCStatusDisconnected];
    deviceModel = nil;
    
    
    AudioServicesPlaySystemSound(1004);
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISCONNECTED object:nil];
    
    [deviceManager stopScan];
}

- (void)didServiceReady:(VTDeviceManager *)dm device:(VTDeviceModel *)device{
    NSLog(@"didServiceReady");
    
    NSLog(@"remembered device UUID = %@, current device UUID = %@", deviceModel.UUID, device.UUID);
    if ([deviceModel.UUID isEqualToString:device.UUID]){
        
        
        deviceModel = device;
        device.delegate = self;
        device.profile.delegate = self;
        
        VTEventModel * event = [device createEvent:VT_EVENT_CONNECTED];
        [device insertEvent:event];
        
        if ([device.profile supportProfile:BLE_SERVICE_DEVICE_INFO]){
            [device.profile readModelNumber:device];
            [device.profile readFirmwareVersion:device];
        }
        
        
        [device.profile setTestResultNotification:device on:YES];
        [device.profile readTestResult:deviceModel];
        
        AudioServicesPlaySystemSound(1003);
        
        [self gotoStatus:VCStatusServiceReady];
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SERVICE_READY object:nil];
        
    }
    
}

- (void) didPaired:(VTDeviceManager*)dm device:(VTDeviceModel *)device{
    NSLog(@"didPaired");
    // not paired
}


- (void) didAdvertised:(VTDeviceManager *)dm device:(VTDeviceModel *)device{
    NSLog(@"didAdvertised");
}

- (void) didDataPushed:(VTDeviceManager *)dm device:(VTDeviceModel *)device advertise:(VTAdvertise *)advertise{
    NSLog(@"didDataPushed ManufactureId = %u type = %d data = %@ deviceName = %@", (unsigned int)advertise.manufactureId, advertise.type, advertise.data, device.name);
    
    if (self.curStatus == VCStatusDisconnected){
        
#if !(TARGET_IPHONE_SIMULATOR)
        VTDeviceModelNumber * modelNumber = [[VTDeviceModelNumber alloc] initWithManufactureData:advertise.data];
        
        if (modelNumber.version == VT_DEVICE_MODEL_VERSION_1 && modelNumber.type == VT_DEVICE_VSCALE){
            
            
            /* If found a new device */
//            NSString *vendorName = NSLocalizedString(@"VTrump", nil);
            NSString *subType;
            
            if(modelNumber.subType == VT_VSCALE_FAT){
                subType = NSLocalizedString(@"Fat Scale",nil);
            }
            
            if(modelNumber.subType == VT_VSCALE_WEIGHT){
                subType = NSLocalizedString(@"Weight Scale",nil);
            }
            
//            NSString *msg = [NSString stringWithFormat:@"%@ %@ %@?", NSLocalizedString(@"Connect to",nil), vendorName,subType];
            //NSLocalizedString(@"Connent to ?",nil);
            
            /*
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Scale Weight", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",nil) otherButtonTitles:NSLocalizedString(@"ok",nil), nil];
            device.delegate = self;
             [alertView show];
             */
//            [_scanDeviceTimer invalidate];
            
            [deviceManager stopScan];
            deviceModel = device;
            
            [self gotoStatus:VCStatusDiscovered];
            
            AudioServicesPlaySystemSound(1002);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [self
             scheduleNotificationOn:[NSDate new]
             text:NSLocalizedString(@"Weight scale detected",nil)
             action:@"View"
             sound:nil
             launchImage:device.imageUrl
             andInfo:nil
             counted:YES
             repeatInterval:0
             enableAtActive:NO];
            
            
            NSArray *tempCompletes = [NSArray arrayWithArray:_scanDeviceCompletes];
            [_scanDeviceCompletes removeAllObjects];
            for (void (^_scanDeviceComplete)(NSError *error) in tempCompletes) {
                _scanDeviceComplete(nil);
            }
        }
#endif
    }
    
}

- (void) didSerialNumberUpdated:(VTDeviceModel *)device serialNumber:(id)serialNumber{
    if ([deviceModel.UUID isEqualToString:device.UUID]){
        NSData * data = serialNumber;
        
        NSLog(@"serial Number is: %@", data.description);
    }
}

- (void) didFirmwareVersionUpdated:(VTDeviceModel *)device version:(NSString *)version{
    if ([deviceModel.UUID isEqualToString:device.UUID]){
        
        NSLog(@"firmware version is: %@", version);
    }
}

- (void) didModelNumberUpdated:(VTDeviceModel *)device modelNumber:(NSData *)modelNumber{
    if ([deviceModel.UUID isEqualToString:device.UUID]){
        
        Byte * modelNumberArray = (Byte*) modelNumber.bytes;
        int modelNumberInt = modelNumberArray[0] * 0x1000000 + modelNumberArray[1] * 0x10000 + modelNumberArray[2]* 0x100 + modelNumberArray[3];
        NSNumber *modelNumberValue = [NSNumber numberWithInt:modelNumberInt];
        [device setMetaData:KEY_MODEL_NUMBER value:modelNumberValue];
        NSLog(@"modelNumber = 0x%x", modelNumberInt);
        
        //[PublicFunction setVSData:@"modelNumber" value:modelNumberValue];
        
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MODEL_NUMBER object:nil];
    }
}

/**
 *	@brief	this method notify the implementer that a Bluetooth4.0 device will autoReconnect if they connected before. the implementer could get the device information for paramter device.
 *
 *	@param 	dm 	device manager
 *	@param 	device 	discovered device
 *  @return
 */
- (Boolean) didAutoReConnect:(VTDeviceManager*)dm device:(VTDeviceModel *)device {
    return YES;
}

/**
 *	@brief	this method notify the implementer that a Bluetooth4.0 device will scan Allow Duplicates Key.
 *
 *	@param 	dm 	device manager
 *	@param 	device 	discovered device
 *  @return
 */
- (Boolean) didScanOptionAllowDuplicatesKey:(VTDeviceManager*)dm {
    return YES;
}

#pragma mark -
#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            if (self.curStatus == VCStatusDiscovered){
                [self gotoStatus:VCStatusDisconnected];
            }
            break;
        case 1:
            //connect device
            [deviceModel  connect];
            break;
            
        default:
            break;
    }
    
}

- (NSDictionary *)transformResult:(VTFatScaleTestResult *)result
{
    return @{
             @"userID" : [NSNumber numberWithInt:result.userID],
             @"gender" : [NSNumber numberWithInt:result.gender],
             @"age" : [NSNumber numberWithInt:result.age],
             @"height" : [NSNumber numberWithInt:result.height],
             @"fatContent" : [NSNumber numberWithFloat:result.fatContent],
             @"waterContent" : [NSNumber numberWithFloat:result.waterContent],
             @"boneContent" : [NSNumber numberWithFloat:result.boneContent],
             @"muscleContent" : [NSNumber numberWithFloat:result.muscleContent],
             @"visceralFatContent" : [NSNumber numberWithInt:result.visceralFatContent],
             @"calorie" : [NSNumber numberWithInt:result.calorie],
             @"bmi" : [NSNumber numberWithFloat:result.bmi],
             };
}

@end
