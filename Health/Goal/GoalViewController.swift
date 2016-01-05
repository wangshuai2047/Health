//
//  GoalViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {

    var viewModel = GoalViewModel()
    
    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var goalDetailLabel: AttributedLabel!
    @IBOutlet weak var suggestCalorieLabel: AttributedLabel!
    
    @IBOutlet weak var connectDeviceView: UIView!
    @IBOutlet weak var sportDetailLabel: AttributedLabel!
    @IBOutlet weak var sleepDetailLabel: AttributedLabel!
    
    @IBOutlet weak var noDeviceView: UIView!
    @IBOutlet weak var noDeviceDetailLabel: AttributedLabel!
    
    @IBOutlet weak var sleepDetailLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sprotDetailLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noDeviceDetailLabelHeightConstraint: NSLayoutConstraint!
    
    let numberFont = UIFont.systemFontOfSize(22)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
        if !GoalManager.isSetGoal {
            let controller = GoalSettingViewController()
            AppDelegate.rootNavgationViewController().pushViewController(controller, animated: true)
        }
        
        showView(GoalManager.isConnectDevice() ? connectDeviceView : noDeviceView)
        userSelectView.setChangeButton(true)
        userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: false)
//        userSelectView.setShowViewUserId(UserManager.mainUser.userId)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - set View
    func refreshView() {
        
        showView(GoalManager.isConnectDevice() ? connectDeviceView : noDeviceView)
        setGoalDetail()
        setSuggestCalorie()
        setConnectDevice()
        setNoDeviceView()
    }
    
    func setGoalDetail() {
        
        
        
        goalDetailLabel.clear()
        if GoalManager.isSetGoal {
            goalDetailLabel.append("您当前设定的目标是", font: nil, color: deepBlue)
            goalDetailLabel.append(" \(UserGoalData.type.description())\n", font: numberFont, color: lightBlue)
            
            
            if let showInfo = GoalManager.currentGoalInfo() {
                
                goalDetailLabel.append("剩余", font: nil, color: deepBlue)
                goalDetailLabel.append(" \(UserGoalData.restDays!) ", font: numberFont, color: lightBlue)
                goalDetailLabel.append("天,还需减", font: nil, color: deepBlue)
                
                if UserGoalData.type == UserGoalData.GoalType.Weight {
                    
                    let weight = String(format: " %.f ", showInfo.needReduceNumber)
                    goalDetailLabel.append(" \(weight) ", font: numberFont, color: lightBlue)
                    goalDetailLabel.append("kg 体重", font: nil, color: deepBlue)
                }
                else if UserGoalData.type == UserGoalData.GoalType.Fat {
                    let weight = String(format: " %.f ", showInfo.needReduceNumber)
                    goalDetailLabel.append(" \(weight) ", font: numberFont, color: lightBlue)
                    goalDetailLabel.append("公斤 脂肪", font: nil, color: deepBlue)
                }
            }
            else {
                goalDetailLabel.append("您还没有使用成分秤评测过,请先评测", font: nil, color: deepBlue)
            }
        }
        else {
            goalDetailLabel.append("您还没有设置目标,请先设置目标", font: nil, color: deepBlue)
        }
    }
    
    func setSuggestCalorie() {
        suggestCalorieLabel.clear()
        if GoalManager.isSetGoal {
            if let showInfo = GoalManager.currentGoalInfo() {
                suggestCalorieLabel.append("建议每天摄入热量", font: nil, color: deepBlue)
                suggestCalorieLabel.append("\(showInfo.dayCalorieGoal)", font: numberFont, color: lightBlue)
                suggestCalorieLabel.append(" kcal", font: nil, color: deepBlue)
            }
            else {
                suggestCalorieLabel.append("您还没有使用成分秤评测过,请先评测", font: nil, color: deepBlue)
            }
        }
        else {
            suggestCalorieLabel.append("您还没有设置目标,请先设置目标", font: nil, color: deepBlue)
        }
    }
    
    func setConnectDevice() {
        setSportDetail()
        setSleepDetail()
    }
    
    func setSportDetail() {
        sportDetailLabel.clear()
        if GoalManager.isSetGoal {
            if let showInfo = GoalManager.currentGoalInfo() {
                sportDetailLabel.append("过去7天内平均每天行走", font: nil, color: deepBlue)
                sportDetailLabel.append("\(showInfo.sevenDaysWalkAverageValue)", font: numberFont, color: lightBlue)
                sportDetailLabel.append(" 步\n为按期达到目标\n建议每天行走", font: nil, color: deepBlue)
                sportDetailLabel.append("\(showInfo.dayWalkGoal)", font: numberFont, color: lightBlue)
                sportDetailLabel.append(" 步\n", font: nil, color: deepBlue)
            }
            else
            {
                sportDetailLabel.append("您还没有使用成分秤评测过,请先评测", font: nil, color: deepBlue)
            }
            
            sprotDetailLabelHeightConstraint.constant = 118
        }
        else {
            sportDetailLabel.append("您还没有设置目标,请先设置目标", font: nil, color: deepBlue)
            sprotDetailLabelHeightConstraint.constant = 0
        }
    }
    
    func setSleepDetail() {
        sleepDetailLabel.clear()
        if GoalManager.isSetGoal {
            if let showInfo = GoalManager.currentGoalInfo() {
                sleepDetailLabel.append("过去7天内平均每天睡", font: nil, color: deepBlue)
                sleepDetailLabel.append("\(showInfo.sevenDaysSleepAverageValue)", font: numberFont, color: lightBlue)
                sleepDetailLabel.append("小时\n为按期达到目标\n建议每天睡眠", font: nil, color: deepBlue)
                sleepDetailLabel.append("8 ", font: numberFont, color: lightBlue)
                sleepDetailLabel.append("小时\n深度睡眠应大于", font: nil, color: deepBlue)
                sleepDetailLabel.append("2 ", font: numberFont, color: lightBlue)
                sleepDetailLabel.append("小时\n", font: nil, color: deepBlue)
            }
            else
            {
                sleepDetailLabel.append("您还没有使用成分秤评测过,请先评测", font: nil, color: deepBlue)
            }
            
            sleepDetailLabelHeightConstraint.constant = 135
        }
        else {
            sleepDetailLabel.append("您还没有设置目标,请先设置目标", font: nil, color: deepBlue)
            sleepDetailLabelHeightConstraint.constant = 0
        }
    }
    
    func setNoDeviceView() {
        noDeviceDetailLabel.clear()
        if GoalManager.isSetGoal {
            if let showInfo = GoalManager.currentGoalInfo() {
                noDeviceDetailLabel.append("为按期达到目标\n建议每天行走", font: nil, color: deepBlue)
                noDeviceDetailLabel.append("\(showInfo.dayWalkGoal)", font: numberFont, color: lightBlue)
                noDeviceDetailLabel.append(" 步\n\n\n建议每天睡眠", font: nil, color: deepBlue)
                noDeviceDetailLabel.append("8", font: numberFont, color: lightBlue)
                noDeviceDetailLabel.append(" 小时\n深度睡眠应大于", font: nil, color: deepBlue)
                noDeviceDetailLabel.append("2", font: numberFont, color: lightBlue)
                noDeviceDetailLabel.append(" 小时\n", font: nil, color: deepBlue)
            }
            else
            {
                noDeviceDetailLabel.append("您还没有使用成分秤评测过,请先评测", font: nil, color: deepBlue)
            }
            
            noDeviceDetailLabelHeightConstraint.constant = 183
        }
        else {
            noDeviceDetailLabel.append("您还没有设置目标,请先设置目标", font: nil, color: deepBlue)
            noDeviceDetailLabelHeightConstraint.constant = 0
        }
        
        
    }

    func showView(view: UIView) {
        noDeviceView.hidden = true
        connectDeviceView.hidden = true
        view.hidden = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Response
    @IBAction func setGoalPressed(sender: AnyObject) {
        let controller = GoalSettingViewController()
        AppDelegate.rootNavgationViewController().pushViewController(controller, animated: true)
    }

    @IBAction func showSportDetailPressed(sender: AnyObject) {
        AppDelegate.rootNavgationViewController().pushViewController(SportDetailViewController(), animated: true)
    }
    
    @IBAction func showSleepDetailPressed(sender: AnyObject) {
        AppDelegate.rootNavgationViewController().pushViewController(SleepDetailViewController(), animated: true)
    }
    
    @IBAction func buyDevicePressed(sender: AnyObject) {
        Alert.showErrorAlert("温馨提示", message: "设备未上线,无法购买!")
    }
    
    @IBAction func bindDevicePressed(sender: AnyObject) {
        
        DeviceScanViewController.showDeviceScanViewController([DeviceType.Bracelet], delegate: self, rootController: AppDelegate.rootNavgationViewController())
    }
}

extension GoalViewController: DeviceScanViewControllerProtocol {
    func didSelected(controller: DeviceScanViewController, device: DeviceManagerProtocol) {
        
        // 绑定
        SettingManager.bindDevice(device)
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在同步手环数据", detailMsg: nil, progress: nil)
        GoalManager.syncDatas ({ [unowned self] (error: NSError?) -> Void in
            if self.respondsToSelector(Selector("refreshView")) {
                self.refreshView()
            }
            
            AppDelegate.applicationDelegate().hiddenHUD()
        })
    }
}
