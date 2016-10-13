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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


let lightBlue = UIColor(red: 121/255.0, green: 199/255.0, blue: 235/255.0, alpha: 1)
let deepBlue: UIColor = UIColor(red: 26/255.0, green: 146/255.0, blue: 214/255.0, alpha: 1)
let lightPink = UIColor(red: 232/255.0, green: 215/255.0, blue: 238/255.0, alpha: 1)
let deepPink: UIColor = UIColor(red: 211/255.0, green: 147/255.0, blue: 235/255.0, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    fileprivate var progressHUD: MBProgressHUD?
    fileprivate var isShowingHUD: Bool = false
    
    var tabBarViewController: UITabBarController? {
        if let navController = window?.rootViewController as? UINavigationController {
            if let tabBarController = navController.viewControllers.first as? UITabBarController {
                return tabBarController
            }
        }
        
        return nil
    }

    class func applicationDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func rootNavgationViewController() -> UINavigationController {
        return AppDelegate.applicationDelegate().window?.rootViewController as! UINavigationController
    }
    
    func changeToLoginController() -> UINavigationController {
        self.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        return self.window?.rootViewController as! UINavigationController
    }
    
    func changeToMainIndex(_ index: Int) {
        if let tabBarController = tabBarViewController {
            
            if index < tabBarController.viewControllers?.count {
                tabBarController.selectedIndex = index
            }
            
        }
    }
    
    func changeToLaunchAnimation() {
        let controller = LaunchAnimationController()
        
        self.window?.rootViewController = controller
    }
    
    func changeToMainController() -> UINavigationController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootNavController = mainStoryboard.instantiateInitialViewController() as! UINavigationController
        self.window?.rootViewController = rootNavController
        return self.window?.rootViewController as! UINavigationController
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ShareSDKHelper.initSDK()
        
        window = UIWindow(frame: UIScreen.main.bounds)
            // [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        let launchAnimationController = LaunchAnimationController.showLaunchAnimationController {[unowned self] () -> Void in
            
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
                navController = self.changeToLoginController()
            }
            else {
                navController = self.changeToMainController()
            }
            navController?.isNavigationBarHidden = true
        }
        
        window?.rootViewController = launchAnimationController
        
        window?.makeKeyAndVisible()
        
        
        progressHUD = MBProgressHUD(window: window)
        
        HealthManager.syncHealthData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        HealthManager.syncHealthData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

enum HUDType {
    case hotwheels  // 只有一个风火轮,加文字
    case progress   // 初始化通讯录时有进度条
    case onlyMsg     // 只有文字
}

extension AppDelegate {
    func updateHUD(_ type: HUDType, message: String?, detailMsg: String?, progress: Float?) {
        switch type {
        case .hotwheels:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.indeterminate
        case .onlyMsg:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.text
        case .progress:
            progressHUD?.labelText = message
            progressHUD?.detailsLabelText = detailMsg
            progressHUD?.mode = MBProgressHUDMode.determinateHorizontalBar
        }
        
        if !isShowingHUD {
            UIApplication.shared.keyWindow?.addSubview(progressHUD!)
            progressHUD?.show(true)
            isShowingHUD = true
        }
    }
    
    func hiddenHUD() {
        isShowingHUD = false
        AppDelegate.applicationDelegate().progressHUD?.hide(true)
    }
}
