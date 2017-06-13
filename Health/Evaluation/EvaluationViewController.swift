//
//  EvaluationViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationViewController: UIViewController {

    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var notConnectDeviceView: UIView!
    @IBOutlet weak var connectDeviceView: UIView!
    
    @IBOutlet weak var manualInputDataView: UIView!
    @IBOutlet weak var weightInputDataTextField: UITextField!
    @IBOutlet weak var waterContentInputDataTextField: UITextField!
    @IBOutlet weak var visceralFatContentInputDataTextField: UITextField!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var evaluationResultView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var metabolismLabel: UILabel!
    @IBOutlet weak var metabolismLevelLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightLevelLabel: UILabel!
    @IBOutlet weak var fattyLiverLabel: UILabel!
    @IBOutlet weak var fattyLiverLevelLabel: UILabel!
    @IBOutlet weak var bodyFatLabel: UILabel!
    @IBOutlet weak var bodyFatLevelLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var canScale: Bool = false
    var timeoutTimer: Timer?
    var scanTime: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        EvaluationManager.sharedInstance.addTestDatas()

        // Do any additional setup after loading the view.\
        self.navigationController?.isNavigationBarHidden = true
        
        userSelectView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 摇一摇
//        UIApplication.shared.applicationSupportsShakeToEdit = true
//        self.becomeFirstResponder()
        
        showView(connectDeviceView)
        self.checkUpBlueToothState()
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "正在同步评测历史数据", detailMsg: nil, progress: nil)
        EvaluationManager.checkAndSyncEvaluationDatas { (error: NSError?) -> Void in
            AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "正在同步手环历史数据", detailMsg: nil, progress: nil)
            // 开始目标数据同步
            GoalManager.checkAndSyncGoalDatas({ (error: NSError?) -> Void in
                
                AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "同步目标数据", detailMsg: nil, progress: nil)
                GoalManager.checkSyncSettingDatas { (error: NSError?) -> Void in
                    AppDelegate.applicationDelegate().hiddenHUD()
                }
            })
        }
        
        
        
    }
    
    func checkUpBlueToothState() {
        EvaluationManager.sharedInstance.setCheckStatusBlock { [unowned self] (status: BluetoothStatus) -> Void in
            
            self.canScale = false
            if status == .poweredOff {
                self.tipLabel.text = "蓝牙未打开,请打开蓝牙!"
            }
            else if status == .unauthorized {
                self.tipLabel.text = "蓝牙未被授权,请在设置中对此应用进行授权!"
            }
            else if status == .unsupported {
                self.tipLabel.text = "设备不支持蓝牙,无法使用!"
            }
            else if status == .poweredOn {
                self.tipLabel.text = "蓝牙已打开，请上秤后点击下方“开始身体评测”按钮，将秤放在坚硬平整的地面上，赤脚测量!"
                self.canScale = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: 0, height: self.scrollView.contentSize.height)
        
        self.view.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userSelectView.setUsers(UserManager.sharedInstance.queryAllUsers(), isNeedExt: true)
        userSelectView.setShowViewUserId(UserManager.sharedInstance.currentUser.userId)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Response Method
    
    @IBAction func backgroundPressed(_ sender: AnyObject) {
        self.weightInputDataTextField.resignFirstResponder()
        self.waterContentInputDataTextField.resignFirstResponder()
        self.visceralFatContentInputDataTextField.resignFirstResponder()
    }
    // MARK: - notConnectDeviceView Response Method
    @IBAction func buyDevicePressed(_ sender: AnyObject) {
//        UIApplication.shared.openURL(URL(string: "https://shop124322383.taobao.com/")!)
        UIApplication.shared.openURL(URL(string: "https://bodivis.m.tmall.com")!)
//        EvaluationManager.sharedInstance.addTestDatas()
    }

    @IBAction func enterMyBodyDataPressed(_ sender: AnyObject) {
        showView(manualInputDataView)
    }
    
    @IBAction func scanMyBodyDevicePressed(_ sender: AnyObject) {
        
        // 现在改为返回评测界面
        self.tipLabel.text = "蓝牙已打开，请上秤后点击下方“开始身体评测”按钮，将秤放在坚硬平整的地面上，赤脚测量!"
        showView(connectDeviceView)
    }
    
    // MARK: - connectDeviceView Response Method 开始测试
    @IBAction func startEvaluationPressed(_ sender: AnyObject) {
        if canScale {
            
            let detailController = EvaluationDetailViewController()
            AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
            
            self.tipLabel.text = "蓝牙已打开，请上秤后点击下方“开始身体评测”按钮，将秤放在坚硬平整的地面上，赤脚测量"
            
            NotificationCenter.default.addObserver(self, selector:#selector(self.notificationMethod), name: NSNotification.Name(rawValue: "removeTimer"), object: nil)
            
//            detailController.middleView.frame = CGRect(x:0,y:100,width:UIScreen.main.bounds.size.width,height:UIScreen.main.bounds.size.height)
//            detailController.middleView.backgroundColor = UIColor.clear
//            detailController.view.addSubview(detailController.middleView)
//            detailController.middleView.isHidden = false
//            AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "搜索设备中(15)s倒计时", detailMsg: nil, progress: nil, currentView: detailController.middleView)
            AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "搜索设备中(15)s倒计时", detailMsg: nil, progress: nil)
            scanTime = 15
            if timeoutTimer != nil {
                if timeoutTimer!.isValid {
                    timeoutTimer?.invalidate()
                }
                timeoutTimer = nil
            }
            
            timeoutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.scanTimerFinished), userInfo: nil, repeats: true)
            
            EvaluationManager.sharedInstance.startScale {[unowned self] (result,isTimeOut, error) -> Void in
                
                if error == nil {
                    
                    detailController.data = result
                    detailController.refreshData()
                    self.showView(self.connectDeviceView)
                } else {
                    
                    if isTimeOut {
                        self.showView(self.notConnectDeviceView)
                    }
                    else {
                        self.showView(self.connectDeviceView)
                        self.tipLabel.text = "评测错误, \(error!.localizedDescription)"
                    }
                    _ = detailController.navigationController?.popViewController(animated: true)
//                    Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
                }
                
                AppDelegate.applicationDelegate().hiddenHUD()
//                detailController.middleView.isHidden = true
            }
        }
        else
        {
            UIAlertView(title: nil, message: "蓝牙未打开,请打开蓝牙", delegate: nil, cancelButtonTitle: "好的").show()
        }
    }
    

    
    // MARK: - manualInputDataView Response Method
    
    @IBAction func manualInputDataCommitPressed(_ sender: AnyObject) {
        
        self.pushToDetailEvaluationViewController(EvaluationManager.sharedInstance.startScaleInputData(self.weightInputDataTextField.text!.floatValue, waterContent: self.waterContentInputDataTextField.text!.floatValue, visceralFatContent: self.visceralFatContentInputDataTextField.text!.floatValue))
        showMainView()
    }
    
    @IBAction func manualInputDataCancelPressed(_ sender: AnyObject) {
        showMainView()
    }
    
    @IBAction func tryEvaluationAgainButtonPressed(_ sender: AnyObject) {
        showMainView()
    }
    
    fileprivate func showMainView() {
        if EvaluationManager.sharedInstance.isConnectedMyBodyDevice {
            showView(connectDeviceView)
        } else {
            showView(notConnectDeviceView)
        }
    }
    
    fileprivate func showView(_ view: UIView) {
        notConnectDeviceView.isHidden = true
        connectDeviceView.isHidden = true
        manualInputDataView.isHidden = true
        evaluationResultView.isHidden = true
        
        view.isHidden = false
    }
    
    func pushToDetailEvaluationViewController(_ data: ScaleResultProtocol) {
        let detailController = EvaluationDetailViewController()
        detailController.data = data
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
    
    func refreshEvaluationResultView(_ info: [String : AnyObject]) {
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == UIEventSubtype.motionShake {
//            startEvaluationPressed(event!)
        }
        
    }
    
    func scanTimerFinished() {
        if scanTime! > 0
        {
            scanTime = scanTime! - 1//"\(scanTime)"
            AppDelegate.applicationDelegate().progressHUD?.labelText = "搜索设备中(" + String(format: "%d", scanTime!) + ")s倒计时"
        }
        else
        {
            timeoutTimer?.invalidate()
            timeoutTimer = nil
        }
        
    }
    
    func notificationMethod()
    {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        NotificationCenter.default.removeObserver(self)
    }
}

extension EvaluationViewController: DeviceScanViewControllerProtocol {
    func didSelected(_ controller: DeviceScanViewController, device: DeviceManagerProtocol) {
        
        // 绑定
//        SettingManager.bindDevice(device)
        
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        self.tipLabel.text = "蓝牙已打开，请上秤后点击下方“开始身体评测”按钮，将秤放在坚硬平整的地面上，赤脚测量"
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "测试中", detailMsg: nil, progress: nil)
        EvaluationManager.sharedInstance.startScale {[unowned self] (info, isTimeOut, error) -> Void in
            if error == nil {
                
                detailController.data = info
                detailController.refreshData()
                //                self.pushToDetailEvaluationViewController(info!)
                self.showView(self.connectDeviceView)
            } else {
                if isTimeOut {
                    self.showView(self.notConnectDeviceView)
                }
                else {
                    self.showView(self.connectDeviceView)
                    self.tipLabel.text = "评测错误, \(error!.localizedDescription)"
                }
                _ = detailController.navigationController?.popViewController(animated: true)
                
//                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
}

extension EvaluationViewController: UserSelectViewDelegate {
    // MARK: -  点击人物头像
    func headButtonPressed(_ userId: Int) {
//        let detailController = EvaluationDetailViewController()
//        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
//        detailController.isRefreshAllData = true
        let detailController = EvaluationDetailViewController()
        detailController.viewModel.reloadData()
        if (detailController.viewModel.allDatas.count > 0)
        {
            AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
            detailController.isRefreshAllData = true
        }
        else
        {
            AppDelegate.applicationDelegate().progressHUD?.yOffset = 200
            AppDelegate.applicationDelegate().updateHUD(HUDType.onlyMsg, message: "没有评测数据", detailMsg: nil, progress: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                AppDelegate.applicationDelegate().hiddenHUD()
                AppDelegate.applicationDelegate().progressHUD?.yOffset = 0
            }
            
        }
    }
    
    // MARK: -  点击访客
    func visitorClicked() {
        let controller = VisitorAddViewController()
        controller.delegate = self
        if #available(iOS 8.0, *) {
            controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else {
            // Fallback on earlier versions
            controller.modalPresentationStyle = UIModalPresentationStyle.currentContext
        }
        // UIModalPresentationFormSheet
        AppDelegate.rootNavgationViewController().present(controller, animated: true) { () -> Void in
            controller.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    // MARK: -  添加家庭成员
    func addFamily() {
        let completeInfoController = CompleteInfoViewController()
        completeInfoController.delegate = self
        completeInfoController.canBack = true
        AppDelegate.rootNavgationViewController().pushViewController(completeInfoController, animated: true)
    }
    
    // MARK: -  用户改变
    func userChangeToUserId(_ userId: Int) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "同步数据", detailMsg: nil, progress: nil)
        
        EvaluationManager.checkAndSyncEvaluationDatas(userId) { [unowned self] (error: NSError?) -> Void in
            
            UserManager.sharedInstance.changeUserToUserId(userId)
            self.userSelectView.setShowViewUserId(userId)
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
}

extension EvaluationViewController: CompleteInfoDelegate {
    // 添加家庭成员
    func completeInfo(_ controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        UserManager.sharedInstance.addUser(user.name, gender: user.gender, age: user.age, height: user.height, imageURL: user.headURL) { [unowned self] (userModel, error: NSError?) -> Void in
            if error == nil {
                UserManager.sharedInstance.changeUserToUserId(userModel!.userId)
                self.userSelectView.setUsers(UserManager.sharedInstance.queryAllUsers(), isNeedExt: true)
                self.userSelectView.setShowViewUserId(userModel!.userId)
                
                _ = controller.navigationController?.popViewController(animated: false)
                
                // 添加家庭成员 后默认是去进行评测
//                self.startEvaluationPressed(NSObject())
            }
            else {
                Alert.showErrorAlert("添加家庭成员失败", message: error?.localizedDescription)
            }
        }
    }
}

// 访客界面代理
extension EvaluationViewController: VisitorAddDelegate {
    func completeInfo(_ controller: VisitorAddViewController, user: UserModel) {
        
        let detailController = EvaluationDetailViewController()
        detailController.isVisitor = true
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "测试中", detailMsg: nil, progress: nil)
        EvaluationManager.sharedInstance.visitorStartScale(user) {[unowned self] (info,isTimeOut, error) -> Void in
            self.tipLabel.text = "蓝牙已打开，请上秤后点击下方“开始身体评测”按钮，将秤放在坚硬平整的地面上，赤脚测量"
            if error == nil {
                
                detailController.data = info
                detailController.refreshData()
                self.showView(self.connectDeviceView)
            } else {
                if isTimeOut {
                    self.showView(self.notConnectDeviceView)
                }
                else {
                    self.showView(self.connectDeviceView)
                    self.tipLabel.text = "评测错误, \(error!.localizedDescription)"
                }
                _ = detailController.navigationController?.popViewController(animated: true)
//                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
            
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
}
