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
    
    var canScale: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        EvaluationManager.shareInstance().addTestDatas()

        // Do any additional setup after loading the view.\
        self.navigationController?.navigationBarHidden = true
        
        userSelectView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
        
        showView(connectDeviceView)
        EvaluationManager.shareInstance().setCheckStatusBlock { [unowned self] (status: CBCentralManagerState) -> Void in
            
            self.canScale = false
            if status == CBCentralManagerState.PoweredOff {
                self.tipLabel.text = "蓝牙未打开,请打开蓝牙!"
            }
            else if status == CBCentralManagerState.Unauthorized {
                self.tipLabel.text = "蓝牙未被授权,请在设置中对此应用进行授权!"
            }
            else if status == CBCentralManagerState.Unsupported {
                self.tipLabel.text = "设备不支持蓝牙,无法使用!"
            }
            else if status == CBCentralManagerState.PoweredOn {
                self.tipLabel.text = "摇一摇请上秤!"
                self.canScale = true
            }
        }
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在同步评测历史数据", detailMsg: nil, progress: nil)
        EvaluationManager.checkAndSyncEvaluationDatas { (error: NSError?) -> Void in
            AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在同步手环历史数据", detailMsg: nil, progress: nil)
            // 开始目标数据同步
            GoalManager.checkAndSyncGoalDatas({ (error: NSError?) -> Void in
                AppDelegate.applicationDelegate().hiddenHUD()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: true)
        userSelectView.setShowViewUserId(UserManager.shareInstance().currentUser.userId)
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
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        self.weightInputDataTextField.resignFirstResponder()
        self.waterContentInputDataTextField.resignFirstResponder()
        self.visceralFatContentInputDataTextField.resignFirstResponder()
    }
    // MARK: - notConnectDeviceView Response Method
    @IBAction func buyDevicePressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://shop124322383.taobao.com/")!)
//        EvaluationManager.shareInstance().addTestDatas()
    }

    @IBAction func enterMyBodyDataPressed(sender: AnyObject) {
        showView(manualInputDataView)
    }
    
    @IBAction func scanMyBodyDevicePressed(sender: AnyObject) {
        
        // 现在改为返回评测界面
        self.tipLabel.text = "摇一摇请上秤!"
        showView(connectDeviceView)
    }
    
    // MARK: - connectDeviceView Response Method
    @IBAction func startEvaluationPressed(sender: AnyObject) {
        
        if canScale {
            let detailController = EvaluationDetailViewController()
            AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
            
            self.tipLabel.text = "已开始扫描，设备请上秤!"
            EvaluationManager.shareInstance().startScale {[unowned self] (result,isTimeOut, error) -> Void in
                
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
                    detailController.navigationController?.popViewControllerAnimated(true)
//                    Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - manualInputDataView Response Method
    
    @IBAction func manualInputDataCommitPressed(sender: AnyObject) {
        
        self.pushToDetailEvaluationViewController(EvaluationManager.shareInstance().startScaleInputData(self.weightInputDataTextField.text!.floatValue, waterContent: self.waterContentInputDataTextField.text!.floatValue, visceralFatContent: self.visceralFatContentInputDataTextField.text!.floatValue))
        showMainView()
    }
    
    @IBAction func manualInputDataCancelPressed(sender: AnyObject) {
        showMainView()
    }
    
    @IBAction func tryEvaluationAgainButtonPressed(sender: AnyObject) {
        showMainView()
    }
    
    private func showMainView() {
        if EvaluationManager.shareInstance().isConnectedMyBodyDevice {
            showView(connectDeviceView)
        } else {
            showView(notConnectDeviceView)
        }
    }
    
    private func showView(view: UIView) {
        notConnectDeviceView.hidden = true
        connectDeviceView.hidden = true
        manualInputDataView.hidden = true
        evaluationResultView.hidden = true
        
        view.hidden = false
    }
    
    func pushToDetailEvaluationViewController(data: ScaleResultProtocol) {
        let detailController = EvaluationDetailViewController()
        detailController.data = data
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
    
    func refreshEvaluationResultView(info: [String : AnyObject]) {
        
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if motion == UIEventSubtype.MotionShake {
            startEvaluationPressed(event!)
        }
        
    }
}

extension EvaluationViewController: DeviceScanViewControllerProtocol {
    func didSelected(controller: DeviceScanViewController, device: DeviceManagerProtocol) {
        
        // 绑定
//        SettingManager.bindDevice(device)
        
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        self.tipLabel.text = "已开始扫描，设备请上秤!"
        EvaluationManager.shareInstance().startScale {[unowned self] (info, isTimeOut, error) -> Void in
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
                detailController.navigationController?.popViewControllerAnimated(true)
                
//                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
        }
    }
}

extension EvaluationViewController: UserSelectViewDelegate {
    // 点击人物头像
    func headButtonPressed(userId: Int) {
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        detailController.isRefreshAllData = true
    }
    
    // 点击访客
    func visitorClicked() {
        let controller = VisitorAddViewController()
        controller.delegate = self
        if #available(iOS 8.0, *) {
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        } else {
            // Fallback on earlier versions
            controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        }
        // UIModalPresentationFormSheet
        AppDelegate.rootNavgationViewController().presentViewController(controller, animated: true) { () -> Void in
            controller.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    // 添加家庭成员
    func addFamily() {
        let completeInfoController = CompleteInfoViewController()
        completeInfoController.delegate = self
        completeInfoController.canBack = true
        AppDelegate.rootNavgationViewController().pushViewController(completeInfoController, animated: true)
    }
    
    // 用户改变
    func userChangeToUserId(userId: Int) {
        UserManager.shareInstance().changeUserToUserId(userId)
        userSelectView.setShowViewUserId(userId)
    }
}

extension EvaluationViewController: CompleteInfoDelegate {
    // 添加家庭成员
    func completeInfo(controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        UserManager.shareInstance().addUser(user.name, gender: user.gender, age: user.age, height: user.height, imageURL: user.headURL) { [unowned self] (userModel, error: NSError?) -> Void in
            if error == nil {
                UserManager.shareInstance().changeUserToUserId(userModel!.userId)
                self.userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: true)
                self.userSelectView.setShowViewUserId(userModel!.userId)
                
                controller.navigationController?.popViewControllerAnimated(false)
                
                // 添加家庭成员 后默认是去进行评测
                self.startEvaluationPressed(NSObject())
            }
            else {
                Alert.showErrorAlert("添加家庭成员失败", message: error?.localizedDescription)
            }
        }
    }
}

// 访客界面代理
extension EvaluationViewController: VisitorAddDelegate {
    func completeInfo(controller: VisitorAddViewController, user: UserModel) {
        
        let detailController = EvaluationDetailViewController()
        detailController.isVisitor = true
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        EvaluationManager.shareInstance().visitorStartScale(user) {[unowned self] (info,isTimeOut, error) -> Void in
            self.tipLabel.text = "已开始扫描，设备请上秤!"
            if error == nil {
                
                detailController.data = info
                self.showView(self.connectDeviceView)
            } else {
                if isTimeOut {
                    self.showView(self.notConnectDeviceView)
                }
                else {
                    self.showView(self.connectDeviceView)
                    self.tipLabel.text = "评测错误, \(error!.localizedDescription)"
                }
                detailController.navigationController?.popViewControllerAnimated(true)
//                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
        }
    }
}
