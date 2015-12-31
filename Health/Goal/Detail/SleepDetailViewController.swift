//
//  SleepDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/24.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

private let cellId = "SleepDetailCell"

class SleepDetailViewController: UIViewController {

    @IBOutlet weak var cicleView: CircleView!
    @IBOutlet weak var lightSleepLabel: UILabel!
    @IBOutlet weak var deepSleepLabel: UILabel!
    @IBOutlet weak var sleepCountLabel: UILabel!
    @IBOutlet weak var sleepDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var sevenDaysData = GoalManager.querySevenDaysData()
    let lightSleepColor = UIColor(red: 166/255.0, green: 188/255.0, blue: 239/255.0, alpha: 1)
    let deepSleepColor = UIColor(red: 89/255.0, green: 125/255.0, blue: 121/255.0, alpha: 1)
    
    convenience init() {
        self.init(nibName: "SleepDetailViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nibCell = UINib(nibName: "GoalDetailTableViewCell", bundle: nil)
        tableView.registerNib(nibCell, forCellReuseIdentifier: cellId)
        
        if GoalManager.isConnectDevice() {
            AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "正在同步手环数据", detailMsg: nil, progress: nil)
            GoalManager.syncDatas({ [unowned self] (error: NSError?) -> Void in
                self.refreshData()
                AppDelegate.applicationDelegate().hiddenHUD()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        // Do any additional setup after loading the view.
        let (_, _, lightSleep, deepSleep) = sevenDaysData.first!
        
        let lightSleepHour = GoalManager.dealSleepMinutesToHours(lightSleep)
        let deepSleepHour = GoalManager.dealSleepMinutesToHours(deepSleep)
        
        lightSleepLabel.text = String(format: "浅层睡眠\n%d小时", arguments: [lightSleepHour])
        deepSleepLabel.text = String(format: "深度睡眠\n%d小时", arguments: [deepSleepHour])
        cicleView.update([(Double(deepSleepHour), deepSleepColor), (Double(lightSleepHour) , lightSleepColor)], animated: true)
        
        let totalSleep = lightSleepHour + deepSleepHour
        sleepCountLabel.text = String(format: "%d", arguments: [totalSleep])
        
        if totalSleep > 8 {
            sleepDescriptionLabel.text = "今天的睡眠时长已达到目标"
        }
        else {
            sleepDescriptionLabel.text =  String(format: "今天还需睡眠%d小时", arguments: [(8 - totalSleep) < 0 ? 0 : (8 - totalSleep)])
        }
        
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        ShareViewController.showShareViewController(self.view.convertToImage(), delegate: self, rootController: self)
    }
    
    @IBAction func syncButtonPressed(sender: AnyObject) {
        if GoalManager.isConnectDevice() {
            GoalManager.syncDatas({ [unowned self] (error: NSError?) -> Void in
                self.refreshData()
                })
        }
    }
    
}

// MARK: - 分享
extension SleepDetailViewController: ShareViewControllerDelegate {
    func shareFinished(shareType: ShareType, error: NSError?) {
        if error == nil {
            Alert.showErrorAlert("分享成功", message: nil)
        }
        else {
            Alert.showErrorAlert("分享失败", message: error?.localizedDescription)
        }
    }
}

extension SleepDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 33
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sevenDaysData.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! GoalDetailTableViewCell
        
        let colors = [lightSleepColor, lightSleepColor, lightSleepColor, deepSleepColor, deepSleepColor]
        let (_, _, lightSleep, deepSleep) = sevenDaysData[indexPath.row + 1]
        let lightSleepHour = GoalManager.dealSleepMinutesToHours(lightSleep)
        let deepSleepHour = GoalManager.dealSleepMinutesToHours(deepSleep)
        
        
        cell.setColors(colors, step: Int(lightSleepHour + deepSleepHour), goalStep: 8, day: indexPath.row + 1, unit: "小时")
        
        return cell
    }
}
