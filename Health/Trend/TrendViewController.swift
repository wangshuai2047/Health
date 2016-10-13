//
//  TrendViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class TrendViewController: UIViewController {
    
    var viewModel = TrendViewModel()

    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var titleDetailView: UIView!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var fatButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var proteinButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartView: DoubleYAxisLineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        chartView.dataSource = self
//        let datas = viewModel.eightDaysDatas()
        userSelectView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        weightButton.isSelected = true
        fatButton.isSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userSelectView.setUsers(UserManager.sharedInstance.queryAllUsers(), isNeedExt: false)
        userSelectView.setShowViewUserId(UserManager.sharedInstance.currentUser.userId)
        viewModel.eightDaysDatas()
        tableView.reloadData()
        chartView.reloadDatas()
        refreshSelectedData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectedButton() -> UIButton? {
        
        if muscleButton.isSelected {
            return muscleButton
        }
        
        if fatButton.isSelected {
            return fatButton
        }
        
        if waterButton.isSelected {
            return waterButton
        }
        
        if proteinButton.isSelected {
            return proteinButton
        }
        
        return nil
    }

    @IBAction func selectButtonPressed(_ button: UIButton) {
        
        if weightButton == button {
            if weightButton.isSelected {
                weightButton.isSelected = false
                refreshSelectedData()
            }
            else {
                if selectCount() > 1 {
                    if let selectButton = selectedButton() {
                        weightButton.isSelected = true
                        selectButton.isSelected = false
                        refreshSelectedData()
                    }
                }
                else {
                    weightButton.isSelected = true
                    refreshSelectedData()
                }
                
            }
        }
        else {
            if button.isSelected {
                button.isSelected = false
                refreshSelectedData()
            }
            else {
                if weightButton.isSelected {
                    if let selectButton = selectedButton() {
                        selectButton.isSelected = false
                        
                    }
                    button.isSelected = true
                    refreshSelectedData()
                }
                else {
                    if selectCount() < 2 {
                        button.isSelected = true
                        refreshSelectedData()
                    }
                }
                
            }
        }
        
        
    }
    
    func refreshSelectedData() {
        var count = 0
        
        viewModel.selectedTag = (nil, nil)
        
        if weightButton.isSelected {
            viewModel.selectedTag = (weightButton.tag, nil)
            count += 1
        }
        
        if fatButton.isSelected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, fatButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (fatButton.tag, nil)
                count += 1
            }
        }
        
        if muscleButton.isSelected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, muscleButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (muscleButton.tag, nil)
                count += 1
            }
        }
        
        if waterButton.isSelected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, waterButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (waterButton.tag, nil)
                count += 1
            }
        }
        
        if proteinButton.isSelected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, proteinButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (proteinButton.tag, nil)
                count += 1
            }
        }
        
        self.chartView.reloadDatas()
    }
    
    func selectCount() -> Int {
        var selectCount: Int = 0
        selectCount += weightButton.isSelected ? 1 : 0
        selectCount += fatButton.isSelected ? 1 : 0
        selectCount += muscleButton.isSelected ? 1 : 0
        selectCount += waterButton.isSelected ? 1 : 0
        selectCount += proteinButton.isSelected ? 1 : 0
        return selectCount
    }
}

extension TrendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.allDatas.count > 5 {
            return 5
        }
        return viewModel.allDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "TrendTableViewDataCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        }
        
        let model: TrendCellViewModel = viewModel.allDatas[viewModel.allDatas.count - 1 - (indexPath as NSIndexPath).row]
        cell?.textLabel?.text = "\(model.timeShowString)"
        cell?.textLabel?.textColor = UIColor.darkGray
        
        let description = String(format: "体重:%.1fkg 体脂:%.1f%%", model.scaleResult.weight, model.scaleResult.fatPercentage)
        cell?.detailTextLabel?.text = description
        cell?.detailTextLabel?.textColor = UIColor.darkGray
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let model: TrendCellViewModel = viewModel.allDatas[indexPath.row]
//        
//        let detailController = EvaluationDetailViewController()
//        detailController.data = model.scaleResult
//        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
}

extension TrendViewController: DoubleYAxisLineChartDataSource {
    
    func chart(_ chart: DoubleYAxisLineChart, colorOfChart isLeftYAxis: Bool) -> UIColor {
        
        return viewModel.chartColor(isLeftYAxis)
    }
    
    func chart(_ chart: DoubleYAxisLineChart, minAndMaxLabelDatasOfYAxis isLeftYAxis: Bool) -> (minValue: Double, maxValue: Double)? {
        
        if isLeftYAxis {
            return viewModel.rangeOfSelectTag(viewModel.selectedTag.0)
        }
        return viewModel.rangeOfSelectTag(viewModel.selectedTag.1)
    }
    
    func chart(_ chart: DoubleYAxisLineChart, valueOfIndex: Int) -> (Double?, Double?, String) {
        
        return viewModel.value(valueOfIndex)
    }
    
    func numberOfDatas(_ chart: DoubleYAxisLineChart) -> Int {
        return viewModel.weightDatas.count
    }
}

extension TrendViewController: UserSelectViewDelegate {
    // 点击人物头像
    func headButtonPressed(_ userId: Int) {
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        detailController.isRefreshAllData = true
    }
    
    // 点击访客
    func visitorClicked() {
        
    }
    
    // 添加家庭成员
    func addFamily() {
    }
    
    // 用户改变
    func userChangeToUserId(_ userId: Int) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "同步数据", detailMsg: nil, progress: nil)
        
        EvaluationManager.checkAndSyncEvaluationDatas(userId) { [unowned self] (error: NSError?) -> Void in
            
            UserManager.sharedInstance.changeUserToUserId(userId)
            self.userSelectView.setShowViewUserId(userId)
            
            // 刷新界面
            self.viewModel.eightDaysDatas()
            self.tableView.reloadData()
            self.chartView.reloadDatas()
            
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
}
