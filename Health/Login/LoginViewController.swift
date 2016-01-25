//
//  YYLoginViewController.swift
//  YYLoginViewController
//
//  Created by Yalin on 15/6/3.
//  Copyright (c) 2015年 yalin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Property
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logoUpConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weiChatLoginButton: UIButton!
    @IBOutlet weak var QQLoginButton: UIButton!
    @IBOutlet weak var weiBoLoginButton: UIButton!
    
    
    @IBOutlet weak var reQueryCaptchasButton: UIButton!
    var reQueryCaptchas: NSTimer?
    var requeryCaptchasTimerCount: Int8 = 0
    
    convenience init() {
        self.init(nibName: "LoginViewController", bundle: nil)
    }
    
    func performOperation(operation :Double -> Double)
    {
        
    }
    
    
    // MARK: - Life Cycle
    deinit {
        // perform the deinitialization
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "登录"
        
        let keyboardShowSelector: Selector = "keyboardShow"
        let keyboardHideSelector: Selector = "keyboardHide"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardShowSelector, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardHideSelector, name: UIKeyboardWillHideNotification, object: nil)
        
        
        // 根据是否安装第三方应用显示图标
//        sina
        QQLoginButton.hidden = !LoginManager.isExistShareApp(ShareType.QQFriend)
        weiChatLoginButton.hidden = !LoginManager.isExistShareApp( ShareType.WeChatTimeline)
        weiBoLoginButton.hidden = !LoginManager.isExistShareApp(ShareType.WeiBo)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - response method
    func dealLoginFinished(name: String?, headURL: String?, error: NSError?) {
        if error == nil {
            // 判断是否需要完善信息
            if LoginManager.isNeedCompleteInfo {
                let completeInfoController = CompleteInfoViewController()
                completeInfoController.delegate = self
                completeInfoController.name = name
                completeInfoController.headURLString = headURL
                self.navigationController?.pushViewController(completeInfoController, animated: true)
            }
            else {
                if let appdelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    appdelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController
                    SettingManager.addLocalNotification()
                }
            }
        }
        else
        {
            UIAlertView(title: error?.domain, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton?) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在登录", detailMsg: nil, progress: nil)
        
        LoginManager.login(self.usernameTextField.text!, captchas: self.passwordTextField.text!) {[unowned self] (error: NSError?) -> Void in
            self.dealLoginFinished(nil, headURL: nil, error: error)
            AppDelegate.applicationDelegate().hiddenHUD()
        }
        backgroundPressed(sender)
    }
    
    @IBAction func backgroundPressed(sender: AnyObject?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    @IBAction func loginWithWeChat(sender: AnyObject) {
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在登录", detailMsg: nil, progress: nil)
        LoginManager.loginThirdPlatform(ThirdPlatformType.WeChat) { [unowned self] (name, headURLStr, error) -> Void in
            self.dealLoginFinished(name, headURL: headURLStr, error: error)
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
    
    @IBAction func loginWithQQ(sender: AnyObject) {
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在登录", detailMsg: nil, progress: nil)
        LoginManager.loginThirdPlatform(ThirdPlatformType.QQ) { [unowned self] (name, headURLStr, error) -> Void in
            self.dealLoginFinished(name, headURL: headURLStr, error: error)
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
    
    @IBAction func loginWithWeiBo(sender: AnyObject) {
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在登录", detailMsg: nil, progress: nil)
        LoginManager.loginThirdPlatform(ThirdPlatformType.Weibo) { [unowned self] (name, headURLStr, error) -> Void in
            self.dealLoginFinished(name, headURL: headURLStr, error: error)
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
    
    @IBAction func reQueryCaptchas(sender: AnyObject) {
        reQueryCaptchasButton.enabled = false
        requeryCaptchasTimerCount = 0
        reQueryCaptchas = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("requeryCaptchasTimer"), userInfo: nil, repeats: true)
        
        LoginManager.queryCaptchas(self.usernameTextField.text) {[unowned self] (authCode:String?, error: NSError?) -> Void in
            if error != nil {
                 UIAlertView(title: error?.domain, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
                self.reQueryCaptchasButton.enabled = true
                self.reQueryCaptchas?.invalidate()
                self.reQueryCaptchasButton.setTitle("发送验证码", forState: UIControlState.Normal)
            }
           
        }
    }
    
    @IBAction func mobileChanged(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://400-880-1089")!)
    }
    
    // MARK: - KeyboardNotification
    func keyboardShow() {
        if !self.usernameTextField.isFirstResponder() && !self.passwordTextField.isFirstResponder() {
            return
        }
        logoUpConstraint.constant = 26 - 195
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardHide() {
        if !self.usernameTextField.isFirstResponder() && !self.passwordTextField.isFirstResponder() {
            return
        }
        
        logoUpConstraint.constant = 26
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - UITextFieldDelegate
    // 按回车可以登录
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            loginButtonPressed(nil)
            return false
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Requery Captchas Timer
    func requeryCaptchasTimer() {
        
        let maxRequeryCount: Int8 = 60
        requeryCaptchasTimerCount++
        reQueryCaptchasButton.setTitle("\(maxRequeryCount - requeryCaptchasTimerCount)秒后 重新发送验证码", forState: UIControlState.Normal)
        
        if requeryCaptchasTimerCount >= maxRequeryCount {
            reQueryCaptchasButton.enabled = true
            reQueryCaptchas?.invalidate()
            reQueryCaptchasButton.setTitle("发送验证码", forState: UIControlState.Normal)
        }
    }
}

extension LoginViewController: CompleteInfoDelegate {
    
    func completeInfo(controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在提交", detailMsg: nil, progress: nil)
        LoginManager.completeInfomation(user.name, gender: user.gender, age: user.age, height: UInt8(user.height), phone: phone, organizationCode: organizationCode, headURL:user.headURL, complete: { (error) -> Void in
            
            if error == nil {
                
                // 跳转到主页
                UserManager.shareInstance().changeUserToUserId(UserManager.mainUser.userId)
                SettingManager.addLocalNotification()
                AppDelegate.applicationDelegate().changeToMainController()
            }
            else {
                UIAlertView(title: "完善信息失败", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
            }
            
            AppDelegate.applicationDelegate().hiddenHUD()
        })
    }
}
