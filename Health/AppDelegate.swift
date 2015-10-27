//
//  AppDelegate.swift
//  Health
//
//  Created by Yalin on 15/8/14.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

/*
#pragma mark - HUD
@property (nonatomic, strong) MBProgressHUD *progressHUD;

- (void)updateHUDWithType:(BT_HUD_TYPE)type message:(NSString *)msg detailMsg:(NSString *)detailMsg progress:(float)progress;

- (void)hiddenHUD;
*/

import UIKit
import CoreData

let lightBlue = UIColor(red: 121/255.0, green: 199/255.0, blue: 235/255.0, alpha: 1)
let deepBlue: UIColor = UIColor(red: 26/255.0, green: 146/255.0, blue: 214/255.0, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var progressHUD: MBProgressHUD?
    private var isShowingHUD: Bool = false
    
    var tabBarViewController: UITabBarController?

    class func applicationDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    class func rootNavgationViewController() -> UINavigationController {
        return AppDelegate.applicationDelegate().window?.rootViewController as! UINavigationController
    }
    
    func changeToLoginController() -> UINavigationController {
        self.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        return self.window?.rootViewController as! UINavigationController
    }
    
    func changeToMainIndex(index: Int) {
        if let tabBarController = tabBarViewController {
            
            if index < tabBarController.viewControllers?.count {
                tabBarController.selectedIndex = index
            }
            
        }
    }
    
    func changeToMainController() -> UINavigationController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootNavController = mainStoryboard.instantiateInitialViewController() as! UINavigationController
        tabBarViewController = rootNavController.viewControllers.first as? UITabBarController
        self.window?.rootViewController = rootNavController
        return self.window?.rootViewController as! UINavigationController
    }
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        ShareSDKHelper.initSDK()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
            // [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        // 判断是否登录 是否跳过GUI 是否跳过广告
        // 进入广告界面
        var navController: UINavigationController?
        if LoginManager.isShowAds {
            let adsController = LoginAdsViewController()
            navController = UINavigationController(rootViewController: adsController)
            self.window?.rootViewController = navController
        }
        else if LoginManager.showedGUI {
            let guiController = GUIViewController()
            navController = UINavigationController(rootViewController: guiController)
            self.window?.rootViewController = navController
        }
        else if !LoginManager.isLogin || LoginManager.isNeedCompleteInfo{
            navController = changeToLoginController()
        }
        else {
            navController = changeToMainController()
        }
        navController?.navigationBarHidden = true
        
        window?.makeKeyAndVisible()
        
        
        progressHUD = MBProgressHUD(window: window)
        
        HealthManager.syncHealthData()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        HealthManager.syncHealthData()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

enum HUDType {
    case Hotwheels  // 只有一个风火轮,加文字
    case Progress   // 初始化通讯录时有进度条
    case OnlyMsg     // 只有文字
}

extension AppDelegate {
    func updateHUD(type: HUDType, message: String?, detailMsg: String?, progress: Float?) {
        switch type {
        case .Hotwheels:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.Indeterminate
        case .OnlyMsg:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.Text
        case .Progress:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.DeterminateHorizontalBar
        }
        
        if !isShowingHUD {
            UIApplication.sharedApplication().keyWindow?.addSubview(progressHUD!)
            progressHUD?.show(true)
            isShowingHUD = true
        }
    }
    
    func hiddenHUD() {
        isShowingHUD = false
        AppDelegate.applicationDelegate().progressHUD?.hide(true)
    }
}
