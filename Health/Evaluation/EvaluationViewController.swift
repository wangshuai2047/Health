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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.\
        self.navigationController?.navigationBarHidden = true
        
        userSelectView.delegate = self
        userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: true)
        self.automaticallyAdjustsScrollViewInsets = false
        
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if EvaluationManager.shareInstance().isConnectedMyBodyDevice {
            showView(connectDeviceView)
        }
        else {
            showView(notConnectDeviceView)
        }
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
        UIApplication.sharedApplication().openURL(NSURL(string: "http://item.jd.com/1295110.html")!)
//        EvaluationManager.shareInstance().addTestDatas()
    }

    @IBAction func enterMyBodyDataPressed(sender: AnyObject) {
        showView(manualInputDataView)
    }
    
    @IBAction func scanMyBodyDevicePressed(sender: AnyObject) {
        DeviceScanViewController.showDeviceScanViewController([DeviceType.MyBody, DeviceType.MyBodyMini, DeviceType.MyBodyPlus], delegate: self, rootController: AppDelegate.rootNavgationViewController())
    }
    
    // MARK: - connectDeviceView Response Method
    @IBAction func startEvaluationPressed(sender: AnyObject) {
        
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        EvaluationManager.shareInstance().startScale {[unowned self] (result, error) -> Void in
            
            if error == nil {
                detailController.data = result
                self.showView(self.connectDeviceView)
            } else {
                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
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
        SettingManager.bindDevice(device)
        
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        
        EvaluationManager.shareInstance().startScale {[unowned self] (info, error) -> Void in
            if error == nil {
                detailController.data = info
                //                self.pushToDetailEvaluationViewController(info!)
                self.showView(self.connectDeviceView)
            } else {
                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
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
        UserManager.shareInstance().addUser(user.name, gender: user.gender, age: user.age, height: user.height) { [unowned self] (userModel, error: NSError?) -> Void in
            if error == nil {
                self.userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: true)
                self.userSelectView.setNeedsDisplay()
                
                controller.navigationController?.popViewControllerAnimated(true)
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
        
        EvaluationManager.shareInstance().visitorStartScale(user) {[unowned self] (info, error) -> Void in
            if error == nil {
                detailController.data = info
                self.showView(self.connectDeviceView)
            } else {
                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
        }
    }
}
